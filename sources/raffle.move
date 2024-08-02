module suipstakes::raffle;

//imports

use sui::tx_context::{Self, TxContext};
use sui::object_table::{Self, ObjectTable};
use sui::transfer;
use sui::package;
use sui::display;

use std::string::{String};


// structs

public struct RAFFLE has drop {}

public struct Raffle has key, store {
    id: UID,
    raffle_name: String,
    raffle_description: String,
}

public struct RaffleShared has key {
    id: UID,
    raffle_id: ID,
    participants: vector<address>,
}

// init function

fun init(otw: RAFFLE, ctx: &mut TxContext){
    let keys = vector[
        b"name".to_string(),
        b"description".to_string(),
    ];
    let values = vector[
        b"{raffle_name}".to_string(),
        b"lets raffle on Sui".to_string(),
    ];

    let publisher = package::claim(otw, ctx);

    let mut display_obj = display::new_with_fields<Raffle>(
        &publisher, keys, values, ctx
    );

    display::update_version(&mut display_obj);

    transfer::public_transfer(display_obj, ctx.sender());
    transfer::public_transfer(publisher, ctx.sender());
}

// functions

entry fun create(
    raffle_name: String,
    raffle_description: String,
    ctx: &mut TxContext
){
    let giveaway_raffle = Raffle{
        id: object::new(ctx),
        raffle_name,
        raffle_description,
    };

    transfer::share_object(
        RaffleShared {
            id: object::new(ctx),
            raffle_id: object::id(&giveaway_raffle),
            participants: vector[],
        }
    );

    transfer::public_transfer(giveaway_raffle, ctx.sender());
}

entry fun participate(
    raffle_shared: &mut RaffleShared,
    ctx: &mut TxContext
){
    raffle_shared.participants.push_back(ctx.sender())
}

