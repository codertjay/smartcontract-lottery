# 0.019 in eth
# 190000000000000000 in wei
import pytest
from brownie import Lottery, accounts, config, network
from web3 import Web3

from scripts.deploy_lottery import deploy_lottery
from scripts.helpful_scripts import LOCAL_BLOCKCHAIN_ENVIRONMENTS


def test_get_entrance_fee():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip()
    lottery = deploy_lottery()
    entrance_fee = lottery.getEntranceFee()
    # Act
    # 2,000 eth /usd
    # usdEntryFee is 50
    #  2000/1 === 5/x == 0.025
    expected_entrance_fee = Web3.toWei(0.025, 'ether')
    assert entrance_fee == expected_entrance_fee
