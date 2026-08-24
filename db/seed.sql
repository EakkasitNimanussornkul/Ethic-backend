-- Seed content for PrivacyLens (run after schema.sql)

insert into modules (slug, title, "order", content, case_study) values
(
  'what-counts-as-personal-data', 'What Counts as Personal Data', 1,
  'Personal data is any information relating to an identified or identifiable person. '
  'It is broader than most people expect: a name or email is obvious, but so are device '
  'identifiers, IP addresses, location trails, and combinations of "anonymous" fields '
  'that together single someone out. As an engineer, the practical question is not '
  '"is this sensitive?" but "could this, alone or combined, point to a real person?" '
  'If the answer is yes, privacy rules apply.',
  'A fitness app published "anonymised" aggregate heat-maps of user activity. Because '
  'the data was granular, the routes revealed the locations and daily routines of staff '
  'at military bases. No names were attached, yet real, identifiable people were exposed '
  '- a reminder that de-identification is not the same as anonymity.'
),
(
  'consent-and-data-minimization', 'Consent and Data Minimization', 2,
  'Data minimization means collecting only what you actually need for a stated purpose, '
  'and keeping it only as long as that purpose lasts. Consent must be informed, specific, '
  'and freely given - a pre-ticked box or a bundled "agree to everything" is not real '
  'consent. When you design a form or an API, every field you request is a decision: each '
  'extra piece of data is extra risk you now own and must protect.',
  'A popular flashlight mobile app requested access to precise location and the contacts '
  'list. A flashlight needs neither. The data was being collected and sold onward. The app '
  'technically had "consent" via its permissions screen, but the collection failed the '
  'minimization test - it gathered far more than its function required.'
);

-- Quiz questions (one scenario each)
insert into quiz_questions (module_id, prompt, scenario, rubric) values
(
  (select id from modules where slug = 'what-counts-as-personal-data'),
  'Should this dataset be treated as personal data? Explain your reasoning and what you would do.',
  'Your team wants to publish a "fully anonymised" dataset of app usage: no names, but each '
  'row has a persistent device ID, timestamps, and GPS coordinates rounded to 3 decimals.',
  'A strong answer recognises that persistent device IDs plus fine-grained location and '
  'timestamps are re-identifiable, so this IS personal data despite having no names. It '
  'should propose mitigations: remove/hash the device ID, coarsen location and time, apply '
  'k-anonymity or aggregation, or not publish. Weak answers call it anonymous because names '
  'were removed.'
),
(
  (select id from modules where slug = 'consent-and-data-minimization'),
  'How would you handle this signup form, and why?',
  'You are building a signup form for a note-taking app. Marketing asks you to also collect '
  'date of birth, phone number, and home address "in case we need them later".',
  'A strong answer applies data minimization: a note-taking app needs none of those fields '
  'to function, so collecting them "just in case" is unjustified and increases risk and '
  'liability. It should push back, collect only what the core purpose requires (e.g. email), '
  'and make anything else optional with a clear purpose and real consent. Weak answers collect '
  'everything because marketing asked.'
);
