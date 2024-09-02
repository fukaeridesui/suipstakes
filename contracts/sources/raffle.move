module suipstakes::raffle;

// === Imports ===

use sui::{
    random::{Random, new_generator},
    vec_set::{Self, VecSet},
};

use std::string::{String};

// === Errors ===

const EDuplicateAddress: u64 = 1;
const EInvalidMinParticipants: u64 = 2;
const EInvalidMaxParticipants: u64 = 3;
const EInvalidParticipantsRange: u64 = 4;
const EParticipantsMaxReached: u64 = 5;
const ENotEnoughParticipants: u64 = 6;
const EInvalidNumberOfWinners: u64 = 7;

// === Structs ===

public struct RAFFLE has drop {}

public struct Raffle has key {
    id: UID,
    title: String,
    description: String,
    prize_in_sui: u64,
    min_participants: u32,
    max_participants: u32,
    start_timestamp: u64,
    end_timestamp: u64,
    participants: VecSet<address>,
    winners: VecSet<address>,
    number_of_winners: u32,
}

// === Functions ===

entry fun create(
    title: String,
    description: String,
    min_participants: u32,
    max_participants: u32,
    number_of_winners: u32,
    ctx: &mut TxContext
){
    assert!(min_participants > 0, EInvalidMinParticipants);
    assert!(max_participants > 0, EInvalidMaxParticipants);
    assert!(min_participants <= max_participants, EInvalidParticipantsRange);
    assert!(number_of_winners >= min_participants && number_of_winners <= max_participants, EInvalidNumberOfWinners);

    let raffle = Raffle {
        id: object::new(ctx),
        title,
        description,
        participants: vec_set::empty(),
        winners: vec_set::empty(),
        min_participants,
        max_participants,
        number_of_winners,
        // [TODO] values are for test and need to be fixed
        prize_in_sui: 100000000,
        start_timestamp: 12345,
        end_timestamp: 12345,
    };

    transfer::share_object(raffle);
}


entry fun participate(
    raffle: &mut Raffle,
    ctx: & TxContext
){
    assert!(raffle.participants.size() as u32 < raffle.max_participants, EParticipantsMaxReached);
    assert!(raffle.participants.contains(&ctx.sender()) == false, EDuplicateAddress);

    raffle.participants.insert(ctx.sender())
}

entry fun run(
    raffle: &mut Raffle,
    random: &Random,
    ctx: &mut TxContext
) {
    assert!(raffle.participants.size() as u32 >= raffle.min_participants, ENotEnoughParticipants);

    let mut random_generator = random.new_generator(ctx);
    let mut i = 0;
    while (i < raffle.number_of_winners) {
        let winner_index = random_generator.generate_u64_in_range(
            0, 
            raffle.participants.size() -1
        );
        let address_list = raffle.participants.keys();
        let winner_address = address_list[winner_index];
        raffle.winners.insert(winner_address);
        raffle.participants.remove(&winner_address);

        i = i + 1;
    }
}
