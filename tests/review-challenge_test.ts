import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.5.4/index.ts';
import { assertEquals } from 'https://deno.land/std@0.170.0/testing/asserts.ts';

Clarinet.test({
    name: "PredictReview: Challenge Creation Test",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const creator = accounts.get('wallet_1')!;
        const block = chain.mineBlock([
            Tx.contractCall('review-challenge', 'create-challenge', [
                types.ascii('Creative Writing Sprint'),
                types.utf8('Submit your most innovative short story'),
                types.ascii('Fiction'),
                types.uint(43200),  // 12 hours duration
                types.uint(43200),  // 12 hours voting
                types.uint(100000), // 0.1 STX submission fee
                types.uint(1000000) // 1 STX stake
            ], creator.address)
        ]);

        // Assert challenge creation succeeded
        block.receipts[0].result.expectOk();
    }
});

Clarinet.test({
    name: "PredictReview: Submission Test",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const creator = accounts.get('wallet_1')!;
        const author = accounts.get('wallet_2')!;

        // First, create a challenge
        const challengeBlock = chain.mineBlock([
            Tx.contractCall('review-challenge', 'create-challenge', [
                types.ascii('Flash Fiction Challenge'),
                types.utf8('Write a compelling story in 500 words'),
                types.ascii('Flash Fiction'),
                types.uint(43200),
                types.uint(43200),
                types.uint(100000),
                types.uint(1000000)
            ], creator.address)
        ]);

        const challengeId = challengeBlock.receipts[0].result.expectOk().expectUint;

        // Then submit a work
        const submissionBlock = chain.mineBlock([
            Tx.contractCall('review-challenge', 'submit-work', [
                types.uint(challengeId),
                types.ascii('Midnight Whispers'),
                types.buff(Buffer.from('sample-ipfs-hash-123456'))
            ], author.address)
        ]);

        // Assert submission succeeded
        submissionBlock.receipts[0].result.expectOk();
    }
});

// Additional tests would cover voting, rewards, following, etc.