#| ## Testing filtering methods for `taxmap` objects
#|
library(taxa)
context("filtering `taxmap` objects")
#|
#| ### Filtering taxa
#|
#| ####  Code shared by tests
obj <- taxmap(taxon_ids = LETTERS[1:5], supertaxon_ids = c(NA, 1, 2, 2, 1),
              obs_taxon_ids = c(2, 2, 1, 1, 3, 4, 5, 3, 3, 4),
              taxon_data = data.frame(name = letters[1:5],  stringsAsFactors = FALSE),
              obs_data = data.frame(obs_attr = LETTERS[1:10],  stringsAsFactors = FALSE))
#|
#| ####  Taxon filtering with NSE
test_that("Taxon filtering with non-standard evaluation works", {
  result <- filter_taxa(obj, n_supertaxa < 2, n_obs > 1,
                        subtaxa = FALSE, supertaxa = TRUE,
                        taxonless = FALSE, reassign_obs = TRUE)
  expect_s3_class(result, "taxmap")
  expect_equivalent(result$taxon_data$name, c("a", "b"))
  expect_equivalent(unname(n_obs(result)), c(10, 7))
})
#|
#| ####  Taxon filtering with taxon_ids
test_that("Taxon filtering with taxon_ids works", {
  result <- filter_taxa(obj, c("A", "B"),
                        subtaxa = FALSE, supertaxa = TRUE,
                        taxonless = FALSE, reassign_obs = TRUE)
  expect_equivalent(result$taxon_data$name, c("a", "b"))
  expect_equivalent(unname(n_obs(result)), c(10, 7))
})
#|
#| ####  Taxon filtering with taxon_data indexes
test_that("Taxon filtering with taxon_data indexes works", {
  result <- filter_taxa(obj, c(1, 2),
                        subtaxa = FALSE, supertaxa = TRUE,
                        taxonless = FALSE, reassign_obs = TRUE)
  expect_equivalent(result$taxon_data$name, c("a", "b"))
  expect_equivalent(unname(n_obs(result)), c(10, 7))
})
#|
#| ####  Taxon filtering with data stored in variables
test_that("Taxon filtering with data stored in variables", {
  input <- c(1, 2)
  result <- filter_taxa(obj, input,
                        subtaxa = FALSE, supertaxa = TRUE,
                        taxonless = FALSE, reassign_obs = TRUE)
  expect_equivalent(result$taxon_data$name, c("a", "b"))
  expect_equivalent(unname(n_obs(result)), c(10, 7))
})
#|
#| ####  Removing observations
test_that("Taxon filtering: removing observations works", {
  result <- filter_taxa(obj, n_obs > 1,
                        subtaxa = FALSE, supertaxa = TRUE,
                        taxonless = FALSE, reassign_obs = FALSE)
  expect_equivalent(result$taxon_data$name, c("a", "b", "c", "d"))
  expect_equivalent(unname(n_obs(result)), c(9, 7, 3, 2))
})
#|
#| ####  Adding NA to filtered observations obs_taxon_ids
test_that("Taxon filtering: NA observations works", {
  result <- filter_taxa(obj, n_obs > 1,
                        subtaxa = FALSE, supertaxa = TRUE,
                        taxonless = TRUE, reassign_obs = FALSE)
  expect_equivalent(result$taxon_data$name, c("a", "b", "c", "d"))
  expect_equal(sum(is.na(obs_data(result))), 1)
})
#|
#| ####  Removing supertaxa works
test_that("Taxon filtering: removing supertaxa works", {
  result <- filter_taxa(obj, n_supertaxa > 0,
                        subtaxa = FALSE, supertaxa = FALSE,
                        taxonless = FALSE, reassign_obs = TRUE)
  expect_equivalent(result$taxon_data$name, c("b", "c", "d", "e"))
  expect_equal(sum(is.na(result$taxon_data$supertaxon_ids)), 2)
})
#|
#| ####  Chaining multiple filtering commands
test_that("Taxon filtering: chaining works", {
  result <- filter_taxa(obj, n_supertaxa > 0,
                        subtaxa = FALSE, supertaxa = FALSE,
                        taxonless = FALSE, reassign_obs = TRUE) %>%
    filter_taxa(n_supertaxa > 0,
                subtaxa = FALSE, supertaxa = FALSE,
                taxonless = FALSE, reassign_obs = TRUE)
  expect_equal(sum(is.na(result$taxon_data$supertaxon_ids)), 2)
  expect_equal(result$taxon_data$taxon_ids, c("C", "D"))
})


#|
#| ### Filtering observations
#|
#| ####  Removing observations without removing taxa
test_that("observation filtering: filtering by logical vector", {
  result <- filter_obs(obj, obs_attr %in% LETTERS[1:5], unobserved = TRUE)
  expect_equivalent(result$obs_data$obs_attr, LETTERS[1:5])
  expect_equal(nrow(taxon_data(result)), nrow(taxon_data(obj)))
})
test_that("observation filtering: filtering by observation data index", {
  result <- filter_obs(obj, 1:5, unobserved = TRUE)
  expect_equivalent(result$obs_data$obs_attr, LETTERS[1:5])
  expect_equal(nrow(taxon_data(result)), nrow(taxon_data(obj)))
})
#|
#| ####  Removing observations while removing taxa
test_that("observation filtering: filtering by logical vector", {
  result <- filter_obs(obj, obs_attr %in% LETTERS[1:5], unobserved = FALSE)
  expect_equivalent(result$obs_data$obs_attr, LETTERS[1:5])
  expect_equal(nrow(taxon_data(result)), 3)
})
