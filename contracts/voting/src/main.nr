// bugs
// something to do with boolean i added into storage
mod types;
contract Voting {
// docs:start:imports
    use dep::aztec::{
        context::{PrivateContext, Context},
        note::{
            note_header::NoteHeader,
            utils as note_utils,
        },
        selector::compute_selector,
         state_vars::{
            map::Map, public_state::PublicState, singleton::Singleton,
        },
        types::type_serialization::{
            bool_serialization::{BoolSerializationMethods, BOOL_SERIALIZED_LEN},
            aztec_address_serialization::{AztecAddressSerializationMethods, AZTEC_ADDRESS_SERIALIZED_LEN},
        },
        types::address::{AztecAddress},

              

    };
    use dep::value_note::{
            balance_utils,
            value_note::{
                ValueNote,
                ValueNoteMethods,
                VALUE_NOTE_LEN,
            },
    };
    use dep::safe_math::SafeU120;
    use dep::easy_private_state::easy_private_state::EasyPrivateUint;

    use crate::types::{SafeU120SerializationMethods, SAFE_U120_SERIALIZED_LEN};

use dep::aztec::oracle::debug_log::{ debug_log, debug_log_field, debug_log_format };

struct Storage {
    admin: PublicState<AztecAddress, AZTEC_ADDRESS_SERIALIZED_LEN>,
    numberOfVotes: Map<Singleton<ValueNote, VALUE_NOTE_LEN>>,
    tally: Map<PublicState<SafeU120, SAFE_U120_SERIALIZED_LEN>>,
    voteEnded: PublicState<bool, BOOL_SERIALIZED_LEN>,
    }

    impl Storage {
        fn init(context: Context) -> Self {
            Storage {
                 admin: PublicState::new(
                    context,
                    1,
                    AztecAddressSerializationMethods,
                ),
                tally: Map::new(
                    context,
                    2,
                    |context, slot| {
                        PublicState::new(
                            context,
                            slot,
                            SafeU120SerializationMethods,
                        )
                    },
                 ),
               numberOfVotes: Map::new(
                    context,
                    3,
                    |context, slot| {
                        Singleton::new(context, slot, ValueNoteMethods)
                    },
                ),
                  voteEnded: PublicState::new(
                    context,
                    4,
                    BoolSerializationMethods,
                )
            }
            }
        }

    #[aztec(private)]
    fn constructor(admin: AztecAddress) {
        context.call_public_function(context.this_address(), compute_selector("set_admin((Field))"), [admin.address]);
        
    }

    #[aztec(public)]
    fn set_admin(admin: AztecAddress) {
      
        storage.admin.write(admin);
        storage.voteEnded.write(false);   
    }

    #[aztec(private)]
      fn cast_vote(owner: Field, vote: Field)  {

        let numberOfVotes = storage.numberOfVotes.at(owner).get_note(true); 
        let zero = ValueNote::new(0, owner);

        assert(numberOfVotes.value != zero.value, "Already voted");
        let newNumberOfVotes = &mut ValueNote::new(numberOfVotes.value - 1, owner);
        storage.numberOfVotes.at(owner).replace(newNumberOfVotes, true);

           context.call_public_function(
            context.this_address(),
            compute_selector("add_to_tally_public(Field)"),
            [vote],
           )
    }

     #[aztec(public)]
     fn add_to_tally_public(vote: Field) {
        let amount = SafeU120::new(1);
        let new_tally = storage.tally.at(vote).read().add(amount);
        storage.tally.at(vote).write(new_tally);
        
     }

    #[aztec(public)]
    fn end_vote() {
        assert(storage.admin.read().eq(AztecAddress::new(context.msg_sender())),
             "Only admin can end votes");
        storage.voteEnded.write(true);
    }

    unconstrained fn get_vote(vote: Field) -> u120 {
        storage.tally.at(vote).read().value
    }
    

    unconstrained fn compute_note_hash_and_nullifier(
    contract_address: Field,
    nonce: Field,
    storage_slot: Field,
    preimage: [Field; VALUE_NOTE_LEN],
    ) -> [Field; 4] {
    let note_header = NoteHeader::new(contract_address, nonce, storage_slot);
    note_utils::compute_note_hash_and_nullifier(ValueNoteMethods, note_header, preimage)
    }

}