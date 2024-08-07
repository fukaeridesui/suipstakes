module suipstakes::raffle;

//imports

use sui::tx_context::{Self, TxContext};
use sui::table_vec::{Self, TableVec};
use sui::transfer;
use sui::package;
use sui::display;

use std::string::{String};


// structs

public struct RAFFLE has drop {}

public struct Raffle has key {
    id: UID,
    title: String,
    description: String,
}

public struct RaffleShared has key {
    id: UID,
    raffle_id: ID,
    participants: TableVec<address>,
    winners: TableVec<address>,
}

// init function

fun init(otw: RAFFLE, ctx: &mut TxContext){
    let keys = vector[
        b"name".to_string(),
        b"description".to_string(),
    ];
    let values = vector[
        b"{title}".to_string(),
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
    title: String,
    description: String,
    ctx: &mut TxContext
){
    let giveaway_raffle = Raffle{
        id: object::new(ctx),
        title,
        description,
    };

    transfer::share_object(
        RaffleShared {
            id: object::new(ctx),
            raffle_id: object::id(&giveaway_raffle),
            participants: table_vec::empty(ctx),
            winners: table_vec::empty(ctx),
        }
    );

    transfer::transfer(giveaway_raffle, ctx.sender());
}

entry fun participate(
    raffle_shared: &mut RaffleShared,
    ctx: & TxContext
){
    raffle_shared.participants.push_back(ctx.sender())
}
