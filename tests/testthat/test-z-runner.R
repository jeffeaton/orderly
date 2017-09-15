context("orderly_runner")

test_that("run: success", {
  path <- prepare_orderly_example("interactive")

  runner <- orderly_runner(path)
  name <- "interactive"
  key <- runner$queue(name)

  expect_equal(runner$status(key),
               list(key = key,
                    status = "queued",
                    id = NA_character_,
                    output = NULL))

  tmp <- runner$poll()
  expect_equal(tmp, "create")
  id <- wait_for_id(runner, key)

  st <- runner$status(key)
  expect_is(st$id, "character")
  expect_equal(st$status, "running")

  dat <- runner$status(key, TRUE)
  expect_equal(names(dat$output), c("stderr", "stdout"))
  expect_match(dat$output$stderr, paste0("\\[ id +\\]  ", id),
               all = FALSE)

  wait_for_path(file.path(path, "draft", name, id, "started"))
  writeLines("continue", file.path(path, "draft", name, id, "resume"))
  wait_while_running(runner)

  dat2 <- runner$status(key, TRUE)
  expect_equal(dat2$status, "success")

  expect_equal(dat2$output$stdout[seq_along(dat$output$stdout)],
               dat$output$stdout)
  expect_equal(dat2$output$stderr[seq_along(dat$output$stderr)],
               dat$output$stderr)
  expect_true(all(lengths(dat2$output) > lengths(dat$output)))
})

test_that("run: error", {
  path <- prepare_orderly_example("interactive")
  runner <- orderly_runner(path)
  dat <- runner_start_interactive(runner)

  writeLines("error", file.path(path, "draft", dat$name, dat$id, "resume"))
  wait_for_process_termination(runner$process$px)

  res <- runner$status(dat$key, TRUE)
  expect_equal(res$status, "running")

  expect_equal(runner$poll(), "finish")
  res <- runner$status(dat$key, TRUE)
  expect_equal(res$status, "failure")
})

test_that("publish", {
  path <- prepare_orderly_example("minimal")
  runner <- orderly_runner(path)

  name <- "example"
  id <- orderly_run(name, config = path, echo = FALSE)
  orderly_commit(id, name, config = path)

  res <- runner$publish(name, id)

  path_yml <- path_orderly_published_yml(file.path(path, "archive", name, id))
  expect_true(file.exists(path_yml))
  expect_equal(yaml_read(path_yml), list(published = TRUE))

  res <- runner$publish(name, id, FALSE)
  expect_equal(yaml_read(path_yml), list(published = FALSE))
})

test_that("rebuild", {
  path <- prepare_orderly_example("minimal")
  runner <- orderly_runner(path)

  name <- "example"
  id <- orderly_run(name, config = path, echo = FALSE)
  orderly_commit(id, name, config = path)

  path_db <- file.path(path, "orderly.sqlite")
  file.remove(path_db)
  expect_silent(runner$rebuild())
  expect_true(file.exists(path_db))
})