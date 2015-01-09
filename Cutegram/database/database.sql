CREATE TABLE IF NOT EXISTS Messages (
    id BIGINT PRIMARY KEY NOT NULL,
    toId BIGINT NOT NULL,
    toPeerType BIGINT NOT NULL,
    unread BOOLEAN NOT NULL,
    fromId BIGINT NOT NULL,
    out BOOLEAN NOT NULL,
    date BIGINT NOT NULL,
    fwdDate BIGINT,
    fwdFromId BIGINT,
    message TEXT,

    actionAddress TEXT,
    actionUserId BIGINT,
    actionPhoto BIGINT,
    actionTitle TEXT,
    actionUsers TEXT,
    actionType BIGINT NOT NULL,
    
    mediaAudio BIGINT,
    mediaLastName TEXT,
    mediaFirstName TEXT,
    mediaPhoneNumber TEXT,
    mediaDocument BIGINT,
    mediaGeo BIGINT,
    mediaPhoto BIGINT,
    mediaUserId BIGINT,
    mediaVideo BIGINT,
    mediaType BIGINT
);
CREATE INDEX "Messages.toId_idx" ON "Messages"("toId");
CREATE INDEX "Messages.fromId_idx" ON "Messages"("fromId");
CREATE INDEX "Messages.out_idx" ON "Messages"("out");
CREATE INDEX "Messages.message_idx" ON "Messages"("message");

CREATE TABLE IF NOT EXISTS PhotoSizes (
    pid BIGINT NOT NULL,
    h BIGINT NOT NULL,
    type TEXT,
    size BIGINT NOT NULL,
    w BIGINT NOT NULL,

    locationLocalId BIGINT NOT NULL,
    locationSecret BIGINT NOT NULL,
    locationDcId BIGINT NOT NULL,
    locationVolumeId BIGINT NOT NULL,
    
    PRIMARY KEY (pid, locationLocalId, locationVolumeId)
);

CREATE TABLE IF NOT EXISTS Photos (
    id BIGINT PRIMARY KEY NOT NULL,
    caption TEXT,
    date BIGINT,
    accessHash BIGINT,
    userId BIGINT
);

CREATE TABLE IF NOT EXISTS Audios (
    id BIGINT PRIMARY KEY NOT NULL,
    dcId BIGINT NOT NULL,
    mimeType TEXT,
    duration BIGINT,
    date BIGINT,
    size BIGINT,
    accessHash BIGINT NOT NULL,
    userId BIGINT,
    type BIGINT
);

CREATE TABLE IF NOT EXISTS Documents (
    id BIGINT PRIMARY KEY NOT NULL,
    dcId BIGINT NOT NULL,
    mimeType TEXT,
    date BIGINT,
    fileName TEXT,
    size BIGINT,
    accessHash BIGINT NOT NULL,
    userId BIGINT,
    type BIGINT
);

CREATE TABLE IF NOT EXISTS Geos (
    id BIGINT PRIMARY KEY NOT NULL,
    longitude DOUBLE NOT NULL,
    lat DOUBLE NOT NULL
);

CREATE TABLE IF NOT EXISTS Videos (
    id BIGINT PRIMARY KEY NOT NULL,
    dcId BIGINT NOT NULL,
    caption TEXT,
    mimeType TEXT,
    date BIGINT,
    duration BIGINT,
    h BIGINT,
    size BIGINT,
    accessHash BIGINT,
    userId BIGINT,
    w BIGINT,
    type BIGINT
);

CREATE TABLE IF NOT EXISTS Dialogs (
    peer BIGINT PRIMARY KEY NOT NULL,
    peerType BIGINT,
    topMessage BIGINT,
    unreadCount BIGINT,
    encrypted BOOLEAN
);

CREATE TABLE IF NOT EXISTS Chats (
    id BIGINT PRIMARY KEY NOT NULL,
    participantsCount BIGINT,
    version BIGINT,
    venue TEXT,
    title TEXT,
    address TEXT,
    date BIGINT,
    geo BIGINT,
    accessHash BIGINT,
    checkedIn BOOLEAN,
    left BOOLEAN,
    type BIGINT,
    
    photoId BIGINT,
    photoBigLocalId BIGINT NOT NULL,
    photoBigSecret BIGINT NOT NULL,
    photoBigDcId BIGINT NOT NULL,
    photoBigVolumeId BIGINT NOT NULL,
    
    photoSmallLocalId BIGINT NOT NULL,
    photoSmallSecret BIGINT NOT NULL,
    photoSmallDcId BIGINT NOT NULL,
    photoSmallVolumeId BIGINT NOT NULL
);
CREATE INDEX "Chats.title_idx" ON "Chats"("title");

CREATE TABLE IF NOT EXISTS Users (
    id BIGINT PRIMARY KEY NOT NULL,
    accessHash BIGINT,
    inactive BOOLEAN,
    phone TEXT,
    firstName TEXT,
    lastName TEXT,
    username TEXT,
    type BIGINT,
    
    photoId BIGINT,
    photoBigLocalId BIGINT NOT NULL,
    photoBigSecret BIGINT NOT NULL,
    photoBigDcId BIGINT NOT NULL,
    photoBigVolumeId BIGINT NOT NULL,
    
    photoSmallLocalId BIGINT NOT NULL,
    photoSmallSecret BIGINT NOT NULL,
    photoSmallDcId BIGINT NOT NULL,
    photoSmallVolumeId BIGINT NOT NULL,
    
    statusWasOnline BIGINT,
    statusExpires BIGINT,
    statusType BIGINT
);
CREATE INDEX "Users.firstName_idx" ON "Users"("firstName");
CREATE INDEX "Users.lastName_idx" ON "Users"("lastName");
CREATE INDEX "Users.username_idx" ON "Users"("username");
CREATE INDEX "Users.phone_idx" ON "Users"("phone");

