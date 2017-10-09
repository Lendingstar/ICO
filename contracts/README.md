# Smart contracts for LendingStar ICO

There will be two smart contracts used for LendingStar ICO. **LSToken**, which will be deployed once and used for all crawdsale phases and **LSSale** which will be deployed once per each crawdsale phase.

## LSToken

It is a ERC20 Token with 100,000,000 (one hundred million) tokens as initial supply. Token supports 18 decimal digits hence smallest token particle is 0.000000000000000001 LST.

During contract construction all minted tokens are put on contract's owner account.

The contract holds an address of LendingStar crowdsale contract. Contract owner should use *setSale()* method to specify which crawdsale contract to use. For each ERC20 token transfer operation (*transfer*, *transferFrom*, *allowance* and *approve*) as well as *increaseApproval* and *decreaseApproval* methods, the token prevents actions mentioned above if specified crowdsale contract is in Active state (in other words: tokens transfers between accounts are prohibited during LendingStar crowdsale event).

Crowdsale contract will claim some amount of tokens to be moved on particular account, using claimTokensFor method. The method can be used by active LendingStar crowdsale contract only.

## LSSale

The crowdsale smart contract allows investors to buy LendingStar tokens during limited period of time. LendingStar will split ICO into several phases. For each crawdsale phase there will be a separate instance of LSSale contract published.

The contract will have the following parameters set once during construction:
- *startTime*, *endTime*: a period of time during which contract is running
- *rate*: how many Wei do you need to buy 0.000000000000000001 LST (minimal particle of token)
- *weiGoal*: maximum amount of funds the contract expected to raise
- *weiMinimalInvestment*: smallest investment that will be allowed by contract. By default it will be set to *rate*. Though for some phases, LendingStart might set this larger than rate 
- *token*: reference to LSToken contract (i.e. which tokens will be used for crawdsale)
- *wallet*: account address that will be used for funds withdrawal

Those parameters are set once and never changed.

The contract holds all investments till crowdsale owner withdraws them by withdraw() method. The funds will be transferred to the 'wallet' address, specified during contract creation.

Investor should use buyTokens() method in order to buy some LSTs. The method will forward appropriate amount of LSTs to sender's address.

## LSSaleWithBonus

The crowdsale smart contract which behaves absolutely like LSSale one for transactions less than 100 Ethers. For larger ones  (larger than 100 Ethers), the amount of tokens that investor receives is calculated based on the following bonus rules:

15% token bonus - for transactions [100 - 300) Ethers
20% token bonus - for transactions [300 - 500) Ethers
25% token bonus - for transactions [500 - 700) Ethers
30% token bonus - for transactions larger than 700 Ethers
