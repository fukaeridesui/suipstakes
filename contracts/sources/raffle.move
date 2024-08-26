module suipstakes::raffle;

// === Imports ===

use sui::tx_context::{Self, TxContext};
use sui::transfer;
use sui::package;
use sui::display;
use sui::random::{Random, new_generator};
use sui::vec_set::{Self, VecSet};

use std::string::{String};

// === Errors ===

const EDuplicateAddress: u64 = 1;

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
    number_of_winners: u8,
}

// === Functions ===

entry fun create(
    title: String,
    description: String,
    ctx: &mut TxContext
){
    let raffle = Raffle{
        id: object::new(ctx),
        title,
        description,
        participants: vec_set::empty<address>(),
        winners: vec_set::empty<address>(),
        //values are for test and need to be fixed
        prize_in_sui: 100000000,
        min_participants: 1,
        max_participants: 100,
        start_timestamp: 12345,
        end_timestamp: 12345,
        number_of_winners: 2
    };

    transfer::share_object(raffle);
}

entry fun participate(
    raffle: &mut Raffle,
    ctx: & TxContext
){
    assert!(raffle.participants.contains(&ctx.sender()) == false, EDuplicateAddress);
    raffle.participants.insert(ctx.sender())
}

entry fun run(
    raffle: &mut Raffle,
    random: &Random,
    ctx: &mut TxContext
) {
    let mut random_generator = random.new_generator(ctx);
    let mut i = 0;
    while (i < raffle.number_of_winners) {
        let winner_index = random_generator.generate_u64_in_range(0, vec_set::size(&raffle.participants) -1);
        let address_list = raffle.participants.keys();
        let winner_address = address_list[winner_index];
        raffle.winners.insert(winner_address);
        raffle.participants.remove(&winner_address);

        i = i + 1;
    }
}