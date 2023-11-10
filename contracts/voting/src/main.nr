// everyone has 1 vote (maybe if its easy to implement 1 each) - we use counter
// they vote yes or no on voteId which pluses or minuses another counter 
// proposal and vote exists in the constructor
// admin who deploys is admin of contract and can call vote_ended 
// vote_ended is private and then sends result to public function, which updates public persistent state
// then anyone can call that public function 
// TODO cant call unconstrained balance utils from constrinaed function - find another way 
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
            map::Map, public_state::PublicState,
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
                ValueNoteMethods,
                VALUE_NOTE_LEN,
            },
    };
    use dep::safe_math::SafeU120;
    use dep::easy_private_state::easy_private_state::EasyPrivateUint;

    use crate::types::{SafeU120SerializationMethods, SAFE_U120_SERIALIZED_LEN};



struct Storage {
    voteCount: Map<EasyPrivateUint>,
    tally: Map<PublicState<SafeU120, SAFE_U120_SERIALIZED_LEN>>,
    admin: PublicState<AztecAddress, AZTEC_ADDRESS_SERIALIZED_LEN>,
    voteEnded: PublicState<bool, BOOL_SERIALIZED_LEN>
    }

    impl Storage {
        fn init(context: Context) -> Self {
            Storage {
                 admin: PublicState::new(
                    context,
                    1,
                    AztecAddressSerializationMethods,
                ),
                voteCount: Map::new(
                    context,
                    1,
                    |context, slot| {
                        EasyPrivateUint::new(context, slot)
                    },
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
                  voteEnded: PublicState::new(
                    context,
                    1,
                    BoolSerializationMethods,
                )
            }
            }
        }

    #[aztec(private)]
    fn constructor(admin: Field) {
        storage.admin.write(AztecAddress::new(admin));
        storage.voteEnded.write(false);   
    }

    #[aztec(private)]
      fn cast_vote(owner: Field, vote: Field)  {
          let voteCount = storage.voteCount;
          // TODO here
         let userVoteCount = balance_utils::get_balance(voteCount.at(owner).set);
        assert(0 == 0, "Already voted");
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