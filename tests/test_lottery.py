# 0.019 in eth
# 190000000000000000 in wei
from brownie import Lottery, accounts, config, network
from web3 import Web3


def test_get_entrance_fee():
    account = accounts[0]
    print('the network',config['networks'][network.show_active()])
    lottery = Lottery.deploy(
        config['networks'][network.show_active()]['eth_usd_price_feed'],
        {'from': account})
    print(lottery)
    assert lottery.getEntranceFee() > Web3.toWei(0.018, 'ether')
    assert lottery.getEntranceFee() < Web3.toWei(0.022, 'ether')
