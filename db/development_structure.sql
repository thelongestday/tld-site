CREATE TABLE `comatose_page_versions` (
  `id` int(11) NOT NULL auto_increment,
  `comatose_page_id` int(11) default NULL,
  `version` int(11) default NULL,
  `parent_id` int(11) default NULL,
  `full_path` text,
  `title` varchar(255) default NULL,
  `slug` varchar(255) default NULL,
  `keywords` varchar(255) default NULL,
  `body` text,
  `filter_type` varchar(25) default 'Textile',
  `author` varchar(255) default NULL,
  `position` int(11) default '0',
  `updated_on` datetime default NULL,
  `created_on` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=195 DEFAULT CHARSET=utf8;

CREATE TABLE `comatose_pages` (
  `id` int(11) NOT NULL auto_increment,
  `parent_id` int(11) default NULL,
  `full_path` text,
  `title` varchar(255) default NULL,
  `slug` varchar(255) default NULL,
  `keywords` varchar(255) default NULL,
  `body` text,
  `filter_type` varchar(25) default 'Textile',
  `author` varchar(255) default NULL,
  `position` int(11) default '0',
  `version` int(11) default NULL,
  `updated_on` datetime default NULL,
  `created_on` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;

CREATE TABLE `events` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `cost` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `invitations` (
  `id` int(11) NOT NULL auto_increment,
  `inviter_id` int(11) default NULL,
  `invitee_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1722 DEFAULT CHARSET=utf8;

CREATE TABLE `orders` (
  `id` int(11) NOT NULL auto_increment,
  `owner_id` int(11) default NULL,
  `state` varchar(255) default NULL,
  `money_received` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `children` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1208 DEFAULT CHARSET=utf8;

CREATE TABLE `paypal_logs` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime default NULL,
  `item_number` int(11) default NULL,
  `quantity` int(11) default NULL,
  `txn_id` varchar(128) default NULL,
  `receiver_id` varchar(128) default NULL,
  `payer_id` varchar(128) default NULL,
  `payment_status` varchar(128) default NULL,
  `mc_gross` float default NULL,
  `mc_fee` float default NULL,
  `invoice` varchar(128) default NULL,
  `mc_currency` varchar(128) default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=136 DEFAULT CHARSET=utf8;

CREATE TABLE `punters` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(128) default NULL,
  `email` varchar(128) default NULL,
  `state` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `salt` varchar(64) default '',
  `salted_password` varchar(64) default '',
  `authentication_token` varchar(16) default NULL,
  `last_login` datetime default NULL,
  `admin` tinyint(1) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1636 DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tickets` (
  `id` int(11) NOT NULL auto_increment,
  `punter_id` int(11) default NULL,
  `order_id` int(11) default NULL,
  `cost` int(11) default NULL,
  `event_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1261 DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('20090331195807');

INSERT INTO schema_migrations (version) VALUES ('20090404152138');

INSERT INTO schema_migrations (version) VALUES ('20090405113812');

INSERT INTO schema_migrations (version) VALUES ('20090407192913');

INSERT INTO schema_migrations (version) VALUES ('20090413150112');

INSERT INTO schema_migrations (version) VALUES ('20090414072528');

INSERT INTO schema_migrations (version) VALUES ('20090418090235');

INSERT INTO schema_migrations (version) VALUES ('20090418090527');

INSERT INTO schema_migrations (version) VALUES ('20090419095044');

INSERT INTO schema_migrations (version) VALUES ('20090420064509');

INSERT INTO schema_migrations (version) VALUES ('20090705133724');