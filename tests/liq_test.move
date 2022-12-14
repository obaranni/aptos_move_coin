#[test_only]
module coin_creator::liq_test {
    use std::option;
    use std::signer;

    use aptos_framework::account;
    use aptos_framework::coin;
    use aptos_std::debug;

    use coin_creator::liq;

    #[test]
    #[expected_failure(abort_code = 100 /* ERR_NO_COIN */)]
    fun mint_before_initialize() {
        let creator_acc = account::create_account_for_test(@coin_creator);

        // try to mint before initialize
        let coins = liq::mint(&creator_acc, 450);
        coin::deposit(signer::address_of(&creator_acc), coins);
    }

    #[test]
    fun test_end_to_end() {
        let creator_acc = account::create_account_for_test(@coin_creator);
        let alice_acc = account::create_account_for_test(@0x11);
        let bob_acc = account::create_account_for_test(@0x12);

        // initialize new coin
        liq::initialize(&creator_acc);

        // check supply
        assert!(option::extract(&mut coin::supply<liq::LIQCoin>()) == 0, 1);

        // simple mint
        let coins = liq::mint(&creator_acc, 150);
        coin::register<liq::LIQCoin>(&alice_acc);
        coin::deposit(signer::address_of(&alice_acc), coins);

        // check supply and balances
        assert!(option::extract(&mut coin::supply<liq::LIQCoin>()) == 150, 1);
        assert!(coin::balance<liq::LIQCoin>(signer::address_of(&alice_acc)) == 150, 1);

        // transfer coins
        coin::register<liq::LIQCoin>(&creator_acc);
        coin::register<liq::LIQCoin>(&bob_acc);
        coin::transfer<liq::LIQCoin>(&alice_acc, signer::address_of(&bob_acc), 50);
        coin::transfer<liq::LIQCoin>(&alice_acc, signer::address_of(&creator_acc), 50);

        // check balances
        assert!(coin::balance<liq::LIQCoin>(signer::address_of(&creator_acc)) == 50, 1);
        assert!(coin::balance<liq::LIQCoin>(signer::address_of(&alice_acc)) == 50, 1);
        assert!(coin::balance<liq::LIQCoin>(signer::address_of(&bob_acc)) == 50, 1);

        // burn some coins
        let coins = coin::withdraw<liq::LIQCoin>(&creator_acc, 50);
        debug::print(&coins);
        let burned = liq::burn(&creator_acc, coins);
        assert!(burned == 50, 1);

        // check supply and balances
        assert!(option::extract(&mut coin::supply<liq::LIQCoin>()) == 100, 1);
        assert!(coin::balance<liq::LIQCoin>(signer::address_of(&creator_acc)) == 0, 1);
        assert!(coin::balance<liq::LIQCoin>(signer::address_of(&alice_acc)) == 50, 1);
        assert!(coin::balance<liq::LIQCoin>(signer::address_of(&bob_acc)) == 50, 1);

        // check if owner try to burn more than have

        // Some hacky tests?
    }
}
