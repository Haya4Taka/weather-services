CREATE TABLE IF NOT EXISTS cities (
  id smallint(6) unsigned NOT NULL PRIMARY KEY,
  name varchar(85) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS weather_hourly (
  id smallint(6) unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  city_id smallint(6) unsigned NOT NULL,
  datetime timestamp NOT NULL,
  weather varchar(85),
  weather_description text,
  temp float,
  humidity tinyint(3),
  pressure smallint(6),
  INDEX (datetime),
  FOREIGN KEY (city_id)
    REFERENCES cities(id)
);

CREATE TABLE IF NOT EXISTS weather_daily (
  id smallint(6) unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  city_id smallint(6) unsigned NOT NULL,
  datetime timestamp NOT NULL,
  weather varchar(85),
  weather_description text,
  temp float,
  humidity tinyint(3),
  pressure smallint(6),
  INDEX (datetime),
  FOREIGN KEY (city_id)
    REFERENCES cities(id)
);