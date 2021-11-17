from brownie import network, accounts, config

DECIMALS = 8
STARTING_PRICE = 200000000000
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ['development', 'ganache-local']
FORKED_LOCAL_ENVIRONMENT = ['mainnet-fork', 'mainnet-fork-dev']


def get_account(index=None, id=None):
    # ganache account accounts[0]
    # accounts.add(".env")
    # accounts.load("id")
    if index:
        return accounts[index]
    if id:
        return accounts.load(id)
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS or \
            network.show_active() in FORKED_LOCAL_ENVIRONMENT:
        return accounts[0]
    return accounts.add(config['wallets']['from_key'])
