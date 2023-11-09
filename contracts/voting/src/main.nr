// everyone has 1 vote (maybe if its easy to implement 1 each) - we use counter
// they vote yes or no on proposal which pluses or minuses another counter 
// proposal and vote exists in the constructor
// admin who deploys is admin of contract and can call vote_ended 
// vote_ended is private and then sends result to public function, which updates public persistent state
// then anyone can call that public function 

contract Counter {
// docs:start:imports
    use dep::aztec::{
        context::{PrivateContext, Context},
        note::{
            note_header::NoteHeader,
            utils as note_utils,
        },
        state_vars::map::Map,
    };
  
    use dep::easy_private_state::easy_private_state::EasyPrivateUint;
// docs:end:imports

// docs:start:storage_struct

    struct Storage {
        counters: Map<EasyPrivateUint>,
        tally: EasyPrivateUint,
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
                tally: EasyPrivateUint::new(
                    context,
                    2
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
      fn increment(owner: Field)  {
        let tally = storage.tally;
        tally.add(1);
    }

// // docs:start:get_counter
//     unconstrained fn get_counter(owner: Field) -> Field {
//     let counters = storage.counters;
//     balance_utils::get_balance(counters.at(owner).set)
//     }
// // docs:end:get_counter

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
