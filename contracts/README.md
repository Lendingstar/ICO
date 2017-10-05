# Smart contracts for Lending Star ICO

There will be two smart contracts used for Lending Star ICO. **LSToken**, which will be deployed once and used for all crawdsale phases and **LSSale** which will be deployed once per each crawdsale phase.

## LSToken

It is a ERC20 Token with 100 000 000 (one hundred million) tokens as initial supply. Token supports 18 decimal digits hence smallest token particle is 0.000000000000000001 LST.

During contract construction all minted tokens are put on contract's owner account.

The contract holds an address of Lending Star crowdsale contract. Contract owner should use *setSale()* method to specify which crawdsale contract to use. For each ERC20 token transfer operation (*transfer*, *transferFrom*, *allowance* and *approve*) as well as *increaseApproval* and *decreaseApproval* methods, the token prevents actions mentioned above if specified crowdsale contract is in Active state (in other words: tokens transfers between accounts are prohibited during Lending Star crowdsale event).

Crowdsale contract can claim some amount of tokens to be moved on particular account, using claimTokensFor method. The method will be used by active Lending Star crowdsale contract only.

