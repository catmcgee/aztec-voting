// everyone has 1 vote (maybe if its easy to implement 1 each) - we use counter
// they vote yes or no on proposal which pluses or minuses another counter
// proposal and vote exists in the constructor
// admin who deploys is admin of contract and can call vote_ended
// vote_ended is private and then sends result to public function, which updates public persistent state
// then anyone can call that public function
mod types;
contract Counter {
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



    struct Storage {
        counters: Map<EasyPrivateUint>,
        // tally: Map<SafeU120>
        tally: Map<PublicState<SafeU120, SAFE_U120_SERIALIZED_LEN>>
    }


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
                        PublicState::new(
                            context,
                            slot,
                            SafeU120SerializationMethods,
                        )
                    },
                ),

            }
        }
    }

    #[aztec(private)]
    fn constructor(proposal: Field, admin: Field) {

    }


    #[aztec(public)]
      fn vote(owner: Field, vote: Field)  {
        let amount = SafeU120::new(1);
        let new_tally = storage.tally.at(vote).read().add(amount);
        storage.tally.at(vote).write(new_tally)
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
