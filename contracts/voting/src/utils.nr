  pub fn eq(self, eq: u120, owner: Field) {
        // Creates new note for the owner.
        let mut note_to_compare = ValueNote::new(eq as Field, owner);

        self.set.insert(&mut addend_note, true);
    }