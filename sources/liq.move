
module coin_creator::liq {
    use std::string;

    use aptos_framework::coin;
    use aptos_framework::coin::{BurnCapability, MintCapability, Coin};
    use std::signer;
    // use aptos_framework::coin::CoinInfo;
    // use aptos_std::debug;
    // use aptos_std::type_info::account_address;
    // use aptos_framework::account;
    // use std::signer;

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

    entry fun mint(owner: &signer, amount: u64) acquires LIQCoinCapabilities {
        assert!(exists<LIQCoinCapabilities>(signer::address_of(owner)), 1);

        let cap = borrow_global<LIQCoinCapabilities>(signer::address_of(owner));
        let coins = coin::mint(amount, &cap.mint_cap);

        coin::deposit(signer::address_of(owner), coins);
    }

    public fun burn() {}
}
