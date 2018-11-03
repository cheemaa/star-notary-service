const StarNotary = artifacts.require('StarNotary')

contract('StarNotary', accounts => {
    let defaultAccount = accounts[0]
    let user1 = accounts[1]
    let user2 = accounts[2]
    let operator = accounts[3]

    beforeEach(async function() { 
        this.contract = await StarNotary.new({from: defaultAccount})
    })

    describe('star existence', () => {
        let dec = "032.155"
        let mag = "245.978"
        let cent = "121.874"
        let tokenId = 1

        it('star does not exist', async function () { 
            assert.equal(await this.contract.checkIfStarExist(dec, mag, cent), false)
        })

        it('star does exist', async function () { 
            await this.contract.createStar("Osa Menor", "La Osa Mayor tenía una hija, llamada Osa Menor", dec, mag, cent, tokenId, {from: user1})
            assert.equal(await this.contract.checkIfStarExist(dec, mag, cent), true)
        })
    })

    describe('can create a star', () => {
        let dec = "032.155"
        let mag = "245.978"
        let cent = "121.874"
        let tokenId = 1

        beforeEach(async function () { 
            tx = await this.contract.createStar("Osa Menor", "La Osa Mayor tenía una hija, llamada Osa Menor", dec, mag, cent, tokenId, {from: user1})
        })

        it('can create a star and get its name', async function () { 
            var starInfo = await this.contract.tokenIdToStarInfo(tokenId)
            assert.equal(starInfo[0], 'Osa Menor')
            assert.equal(starInfo[1], 'La Osa Mayor tenía una hija, llamada Osa Menor')
            assert.equal(starInfo[2], "ra_" + cent)
            assert.equal(starInfo[3], "dec_" + dec)
            assert.equal(starInfo[4], "mag_" + mag)
        })

        it('ownerOf tokenId is user1', async function () {
            assert.equal(await this.contract.ownerOf(tokenId), user1)
        })

        it('balanceOf user1 is incremented by 1', async function () { 
            let balance = await this.contract.balanceOf(user1)

            assert.equal(balance.toNumber(), 1)
        })

        it('emits the correct event during creation of a new token', async function () { 
            assert.equal(tx.logs[0].event, 'Transfer')
        })
    })

    /*describe('buying and selling stars', () => { 

        let user1 = accounts[1]
        let user2 = accounts[2]

        let starId = 1
        let starPrice = web3.toWei(.01, "ether")

        beforeEach(async function () {
            await this.contract.createStar('awesome star', starId, {from: user1})
        })

        describe('user1 can sell a star', () => { 
            it('user1 can put up their star for sale', async function () { 
                await this.contract.putStarUpForSale(starId, starPrice, {from: user1})

                assert.equal(await this.contract.starsForSale(starId), starPrice)
            })

            it('user1 gets the funds after selling a star', async function () { 
                let starPrice = web3.toWei(.05, 'ether')

                await this.contract.putStarUpForSale(starId, starPrice, {from: user1})

                let balanceOfUser1BeforeTransaction = web3.eth.getBalance(user1)
                await this.contract.buyStar(starId, {from: user2, value: starPrice})
                let balanceOfUser1AfterTransaction = web3.eth.getBalance(user1)

                assert.equal(balanceOfUser1BeforeTransaction.add(starPrice).toNumber(), 
                            balanceOfUser1AfterTransaction.toNumber())
            })
        })

        describe('user2 can buy a star that was put up for sale', () => { 
            beforeEach(async function () { 
                await this.contract.putStarUpForSale(starId, starPrice, {from: user1})
            })

            it('user2 is the owner of the star after they buy it', async function () { 
                await this.contract.buyStar(starId, {from: user2, value: starPrice})

                assert.equal(await this.contract.ownerOf(starId), user2)
            })

            it('user2 correctly has their balance changed', async function () { 
                let overpaidAmount = web3.toWei(.05, 'ether')

                const balanceOfUser2BeforeTransaction = web3.eth.getBalance(user2)
                await this.contract.buyStar(starId, {from: user2, value: overpaidAmount, gasPrice:0})
                const balanceAfterUser2BuysStar = web3.eth.getBalance(user2)

                assert.equal(balanceOfUser2BeforeTransaction.sub(balanceAfterUser2BuysStar), starPrice)
            })
        })
    })*/
})