// everyone has 1 vote (maybe if its easy to implement 1 each) - we use counter
// they vote yes or no on proposal which pluses or minuses another counter 
// proposal and vote exists in the constructor
// admin who deploys is admin of contract and can call vote_ended 
// vote_ended is private and then sends result to public function, which updates public persistent state
// then anyone can call that public function 
mod types;
contract Counter {
// docs:start:imports
    use dep::aztec::{
        context::{PrivateContext, Context},
        note::{
            note_header::NoteHeader,
            utils as note_utils,
        },
         state_vars::{
            immutable_singleton::ImmutableSingleton, map::Map, public_state::PublicState, set::Set,
            singleton::Singleton,
        },
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
    use dep::field_note::field_note::{FieldNote, FieldNoteMethods, FIELD_NOTE_LEN};

    use crate::types::{SafeU120SerializationMethods, SAFE_U120_SERIALIZED_LEN};

// docs:end:imports

// docs:start:storage_struct

    struct Storage {
        counters: Map<EasyPrivateUint>,
        tally: Map<SafeU120>
    }

// docs:end:storage_struct

// docs:start:storage_init
    impl Storage {
        fn init(context: Context) -> pub Self {
            Storage {
                counters: Map::new(
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
                        SafeU120::new(0)
                    },
                ),

            }
        }
    }
// docs:end:storage_init

// docs:start:constructor
    #[aztec(private)]
    fn constructor(proposal: Field, admin: Field) {

    }
// docs:end:constructor


    #[aztec(private)]
      fn vote(owner: Field, vote: Field)  {
        let tally = storage.tally;
        let mut thing = tally.at(vote);
        let a = SafeU120::new(1);
        let res = SafeU120::add(thing, a);
        thing = res;
    }

    unconstrained fn get_vote(vote: Field) -> Field {
        let tally = storage.tally;
        SafeU120SerializationMethods.deserialize(res)
        let res = tally.at(vote).deserializeU120();
    }
    

// docs:start:nullifier
    unconstrained fn compute_note_hash_and_nullifier(
    contract_address: Field,
    nonce: Field,
    storage_slot: Field,
    preimage: [Field; VALUE_NOTE_LEN],
    ) -> [Field; 4] {
    let note_header = NoteHeader::new(contract_address, nonce, storage_slot);
    note_utils::compute_note_hash_and_nullifier(ValueNoteMethods, note_header, preimage)
    }
// docs:end:nullifier
}
