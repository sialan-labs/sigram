-- -----------------------------------------------------
-- Table Messages
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Messages (
  id BIGINT NOT NULL,
  body TEXT NOT NULL,
  mdate BIGINT NOT NULL,
  isOut TINYINT(1) NOT NULL,
  unread TINYINT(1) NOT NULL,
  fromId BIGINT NOT NULL,
  toId BIGINT NOT NULL,
  PRIMARY KEY (id));


-- -----------------------------------------------------
-- Table Dialogs
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Dialogs (
  id BIGINT NOT NULL,
  isChat INT NOT NULL DEFAULT 0,
  unread INT NOT NULL DEFAULT 0,
  ldate BIGINT NULL,
  lastMsg TEXT NULL,
  photo TEXT NULL,
  title TEXT NULL,
  firstname TEXT NULL,
  lastname TEXT NULL,
  phone TEXT NULL,
  PRIMARY KEY (id));


-- -----------------------------------------------------
-- Table Mutes
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Mutes (
  id BIGINT NOT NULL,
  mute TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id));

