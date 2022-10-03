#[test_only]
module coin_creator::e2e_1 {
    use aptos_framework::account;
    use std::option;
    use aptos_framework::coin;
    use coin_creator::liq::LIQCoin;
    use std::signer;

    public fun create_account(addr: address): signer {
        account::create_account_for_test(addr)
    }

    #[test]
    #[expected_failure(abort_code = 100 /* ENO_COIN */)]
    fun mint_before_initialize() {
        let creator_acc = create_account(@coin_creator);

        // try to mint before initialize
        let coins = coin_creator::liq::mint(&creator_acc, 450);
        coin::deposit(signer::address_of(&creator_acc), coins);
    }

    #[test]
    #[expected_failure(abort_code = 100 /* ENO_COIN */)]
    fun burn_before_initialize() {
        let creator_acc = create_account(@coin_creator);

        // try to burn before initialize
        coin_creator::liq::burn(&creator_acc, 10);
    }

    #[test]
    fun test_coin_initialize() {
        let creator_acc = create_account(@coin_creator);
        let alice_acc = create_account(@0x11);
        let bob_acc = create_account(@0x12);

        // initialize new coin
        coin_creator::liq::initialize(&creator_acc);

        // check supply and balances
        assert!(option::extract(&mut coin::supply<LIQCoin>()) == 0, 1);
        assert!(coin::balance<LIQCoin>(signer::address_of(&creator_acc)) == 0, 1);

        // simple mint
        let coins = coin_creator::liq::mint(&creator_acc, 150);
        coin::register<LIQCoin>(&alice_acc);
        coin::deposit(signer::address_of(&alice_acc), coins);

        // check supply and balances
        assert!(option::extract(&mut coin::supply<LIQCoin>()) == 150, 1);
        assert!(coin::balance<LIQCoin>(signer::address_of(&creator_acc)) == 0, 1);
        assert!(coin::balance<LIQCoin>(signer::address_of(&alice_acc)) == 150, 1);

        // transfer coins
        coin::register<LIQCoin>(&bob_acc);
        coin::transfer<LIQCoin>(&alice_acc, signer::address_of(&bob_acc), 50);
        coin::transfer<LIQCoin>(&alice_acc, signer::address_of(&creator_acc), 50);

        // check balances
        assert!(coin::balance<LIQCoin>(signer::address_of(&creator_acc)) == 50, 1);
        assert!(coin::balance<LIQCoin>(signer::address_of(&alice_acc)) == 50, 1);
        assert!(coin::balance<LIQCoin>(signer::address_of(&bob_acc)) == 50, 1);

        // burn some coins
        let burned = coin_creator::liq::burn(&creator_acc, 50);
        assert!(burned == 50, 1);

        // check supply and balances
        assert!(option::extract(&mut coin::supply<LIQCoin>()) == 100, 1);
        assert!(coin::balance<LIQCoin>(signer::address_of(&creator_acc)) == 0, 1);
        assert!(coin::balance<LIQCoin>(signer::address_of(&alice_acc)) == 50, 1);
        assert!(coin::balance<LIQCoin>(signer::address_of(&bob_acc)) == 50, 1);

        // check if owner try to burn more than have

        // Some hacky tests?
    }
}
