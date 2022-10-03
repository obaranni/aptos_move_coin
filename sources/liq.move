
module coin_creator::liq {
    use std::signer;
    use std::string;

    use aptos_framework::coin::{Self, BurnCapability, MintCapability, Coin};

    // coin does not exist
    const ENO_COIN: u64 = 100;

    struct LIQCoin {}

    struct LIQCoinCapabilities has key {
        burn_cap: BurnCapability<LIQCoin>,
        mint_cap: MintCapability<LIQCoin>,
    }

    public fun initialize(sender: &signer) {
        let (burn_cap, freeze_cap, mint_cap) =  coin::initialize<LIQCoin>(
            sender,
            string::utf8(b"LIQCoin"),
            string::utf8(b"LIQ"),
            6,
            true
        );
        coin::destroy_freeze_cap(freeze_cap);

        coin::register<LIQCoin>(sender);
        move_to(sender, LIQCoinCapabilities {
            burn_cap,
            mint_cap,
        });
    }

    public fun mint(owner: &signer, amount: u64): Coin<LIQCoin> acquires LIQCoinCapabilities {
        assert!(exists<LIQCoinCapabilities>(signer::address_of(owner)), ENO_COIN);

        let cap = borrow_global<LIQCoinCapabilities>(signer::address_of(owner));

        coin::mint(amount, &cap.mint_cap)
    }

    public fun burn(owner: &signer, amount: u64): u64 acquires  LIQCoinCapabilities {
        assert!(exists<LIQCoinCapabilities>(signer::address_of(owner)), ENO_COIN);

        let cap = borrow_global<LIQCoinCapabilities>(signer::address_of(owner));
        let coin = coin::withdraw<LIQCoin>(owner, amount);

        coin::burn<LIQCoin>(coin, &cap.burn_cap);
        amount
    }
}
