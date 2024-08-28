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
}

// === Functions ===

entry fun create(
    title: String,
    description: String,
    min_participants: u32,
    max_participants: u32,
    ctx: &mut TxContext
){
    assert!(min_participants > 0, EInvalidMinParticipants);
    assert!(max_participants > 0, EInvalidMaxParticipants);
    assert!(min_participants <= max_participants, EInvalidParticipantsRange);

    // TODO: number_of_winners の引数を追加後、 min_participants, max_participants と同様にバリデーションを追加する

    let raffle = Raffle {
        id: object::new(ctx),
        title,
        description,
        participants: vec_set::empty(),
        winners: vec_set::empty(),
        //values are for test and need to be fixed
        prize_in_sui: 100000000,
        min_participants,
        max_participants,
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
    let winner_index = random_generator.generate_u64_in_range(
        0, vec_set::size(&raffle.participants) - 1
    );
    let addr = raffle.participants.keys();
    raffle.winners.insert(addr[winner_index]);
}
