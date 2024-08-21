module suipstakes::raffle;

// === Imports ===

use sui::tx_context::{Self, TxContext};
use sui::table_vec::{Self, TableVec};
use sui::transfer;
use sui::package;
use sui::display;
use sui::random::{Random, new_generator};

use std::string::{String};


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
    participants: TableVec<address>,
    winners: TableVec<address>,
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
        participants: table_vec::empty(ctx),
        winners: table_vec::empty(ctx),
        //values are for test and need to be fixed
        prise_in_sui: 100000000,
        min_participants: 1,
        max_participants: 100,
        start_timestamp: 12345,
        end_timestamp: 12345,
    };

    transfer::share_object(raffle);
}

entry fun participate(
    raffle: &mut Raffle,
    ctx: & TxContext
){
    raffle.participants.push_back(ctx.sender())
}

entry fun run(
    raffle: &mut Raffle,
    random: &Random,
    ctx: &mut TxContext
) {
    let mut random_generator = random.new_generator(ctx);
    let winner_index = random_generator.generate_u64_in_range(
        0, table_vec::length(&raffle.participants) - 1
    );
    raffle.winners.push_back(raffle.participants[winner_index as u64]);
}