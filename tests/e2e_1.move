#[test_only]
module coin_creator::e2e_1 {
    use aptos_framework::account;
    use aptos_std::debug;
    use aptos_framework::coin;
    use coin_creator::liq::LIQCoin;
    use std::signer;
    // use aptos_std::debug;
    // use coin_creator::liq::LIQCoinCapabilities;
    // use std::signer;

    public fun create_account(): signer {
        account::create_account_for_test(@coin_creator)
    }

    #[test]
    fun test_coin_initialize() {
        let creator_acc = create_account();

        coin_creator::liq::initialize(&creator_acc);

        coin_creator::liq::mint(&creator_acc, 150);
        coin_creator::liq::mint(&creator_acc, 150);
        // 0x1::liq::initialize(&creator_acc);
        debug::print(&coin::balance<LIQCoin>(signer::address_of(&creator_acc)));
    }

}
