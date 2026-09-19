-- What a Claude call COST, not only how many tokens it processed.
--
-- apps/character-creator/INGESTION-AUDIT.md F35, from the paragraph F23 ended
-- on. With prompt caching, a response reports the cached span separately -
-- `cache_creation_input_tokens` for a write, `cache_read_input_tokens` for a
-- hit - and the two bill very differently: a read at 0.1x the input price, a
-- write at 1.25x. `input_tokens` here is the TOTAL the call processed (the
-- extractor has summed the three since F23, and the proxy's recorder does from
-- this change on), so a row reading 21,581 could be three different prices and
-- could not say which.
--
-- NULL MEANS THE RESPONSE CARRIED NO FIGURE, 0 MEANS IT SAID ZERO. Every row
-- written before this migration is NULL in both, which is the truth about them:
-- nothing recorded the split. None of those 28 rows used the cache anyway
-- (F35, measured `--remote` 2026-09-19).
--
-- Record only. Nothing on a request path reads these, and both writers stay
-- fail-open. APPLY THIS BEFORE THE CODE THAT NAMES THE COLUMNS: an INSERT naming
-- a column the table lacks fails, and the fail-open catch would drop the row
-- without a word.

ALTER TABLE claude_usage ADD COLUMN cache_write_tokens INTEGER;
ALTER TABLE claude_usage ADD COLUMN cache_read_tokens INTEGER;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('077-claude-usage-cache-tokens.sql');
