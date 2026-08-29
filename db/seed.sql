-- Seed content for PrivacyLens (run after schema.sql).

insert into modules (slug, title, summary, "order", sections) values
(
  'what-counts-as-personal-data',
  'What Counts as Personal Data',
  'Learn to recognise personal data — including the identifiers most people miss.',
  1,
  $json$[{"heading": "The everyday definition", "body": "Personal data is any information relating to an identified or identifiable person. That definition is deliberately broad, and it reaches much further than most people assume. A name, email address, or phone number is obviously personal data, but so is anything that can be traced back to a specific human being — directly or indirectly.\n\nIt helps to split identifiers into two groups. Direct identifiers point at someone on their own: a full name, a national ID number, a face in a photo. Indirect identifiers don't name anyone by themselves, but combined with other data they narrow the field down to one person: a job title at a small company, a birth date, a home postcode.\n\nAs an engineer, the useful question is not \"does this feel sensitive?\" but \"could this data, on its own or combined with something else, point to a real person?\" If the answer is yes, then privacy obligations apply — regardless of whether the field looks harmless in isolation. Getting into the habit of asking that question every time you add a column or log a new event is one of the most practical privacy skills you can build."}, {"heading": "Identifiers you might miss", "body": "The identifiers that cause the most trouble are the ones people forget to count. Device and advertising IDs, IP addresses, cookie identifiers, and precise GPS trails are all personal data, because each can be tied back to an individual over time. A persistent device ID that follows a phone around is, in practice, a name you just can't read.\n\nEven fields that look completely anonymous can single someone out when you combine them. These are called quasi-identifiers. A famous study found that around 87% of the US population could be uniquely identified from just three fields: birth date, postcode, and gender — none of which is a name. Put a few \"harmless\" columns together and you may have effectively re-created an identity.\n\nThis is why \"we removed the names, so it's anonymous\" is one of the most common and expensive mistakes in data handling. Anonymisation is hard: it means making sure no combination of the remaining fields can re-identify someone, not just deleting the obvious column. When you're unsure, treat quasi-identifiers with the same care as direct ones."}, {"heading": "Case study: the anonymised heat-map", "body": "In 2018 a popular fitness app published a global \"heat-map\" showing aggregated exercise routes from its users. The data was described as anonymised — there were no names, no usernames, just glowing lines of activity on a world map. It looked like the definition of harmless, aggregate data.\n\nThe problem appeared in remote places. In areas where almost the only people wearing fitness trackers were soldiers and contractors, the heat-map traced the perimeters, patrol routes, and daily jogging paths of military bases — some of them not publicly known. From aggregate, name-free data, analysts could infer the location of individuals and the routines of specific facilities.\n\nThe lesson is twofold. First, de-identification is not the same as anonymity: stripping names does not stop granular data from revealing people. Second, aggregate data can still leak individual information, especially when the group is small or unusual. Before you publish or share any dataset, ask what could be inferred from it in the worst case — not just what it looks like at first glance."}]$json$::jsonb
),
(
  'consent-and-data-minimization',
  'Consent and Data Minimization',
  'Collect only what you need, and learn what real, informed consent looks like.',
  2,
  $json$[{"heading": "Minimization: collect only what you need", "body": "Data minimization is the principle of collecting only the data you genuinely need for a clearly stated purpose, and keeping it only as long as that purpose lasts. It sounds obvious, but it runs against a strong instinct in product teams: the urge to grab everything now \"in case it's useful later.\"\n\nThe reason minimization matters is that every field you collect is a liability, not just an asset. Data you hold is data you must secure, store, back up, explain in a privacy policy, and potentially disclose after a breach. If you never collected a piece of information, it can't be leaked, subpoenaed, misused, or stolen. The safest data is the data you never collected.\n\nMinimization also applies to time. Holding records forever multiplies risk for no benefit, so purposes should come with retention limits and deletion routines. In practice this means pushing back on \"collect it just in case\" requests, making optional fields genuinely optional, and periodically asking of every field you store: do we still need this, and why? A smaller data footprint is easier to protect and easier to trust."}, {"heading": "What real consent looks like", "body": "Consent is one of the most misunderstood ideas in privacy. For consent to be meaningful it has to be informed, specific, and freely given. Informed means the person actually understands what they're agreeing to. Specific means they're agreeing to a particular use, not a vague catch-all. Freely given means they can say no — including saying no to some things and yes to others — without being punished or blocked from the core service.\n\nA lot of what passes for consent fails these tests. A pre-ticked checkbox is not consent, because the user never made an active choice. A single \"I agree to everything\" wall that bundles essential functionality together with analytics, advertising, and third-party sharing is not specific, and it isn't freely given if declining means you can't use the app at all. Burying data practices in dense legal text defeats the \"informed\" part.\n\nGood consent looks different: clear plain-language explanations, separate opt-ins for separate purposes, non-essential options off by default, and an easy way to withdraw consent later. If a user would be surprised to learn what you're doing with their data, you probably don't have real consent."}, {"heading": "Case study: the flashlight app", "body": "A few years ago, several of the most-downloaded flashlight apps on mobile stores asked for permissions that had nothing to do with turning on a light. One well-known example requested access to the user's precise location and their full contacts list. A flashlight needs neither — it needs the camera flash and nothing else.\n\nThe extra data wasn't a mistake. Location and contact information were being collected and sold onward to data brokers; the \"free\" flashlight was really a data-collection business. Technically the app showed a permissions screen, so a user had \"agreed.\" But that agreement was neither specific nor meaningful: nothing about a flashlight's function explains why it would need your movements or your friends' phone numbers.\n\nThis case fails both principles from this module at once. It fails minimization, because it collected far more than its purpose required. And it fails consent, because the permission prompt gave no real understanding of what was happening or why. When you review the data your own product asks for, use the flashlight test: for each field and permission, can you clearly justify it from the app's actual purpose? If not, don't collect it."}]$json$::jsonb
);

-- ===== Questions: Module 1 ==================================================
insert into quiz_questions (module_id, "order", type, prompt, scenario, options, correct_answer, rubric)
select id, q."order", q.type, q.prompt, q.scenario, q.options, q.correct_answer, q.rubric
from modules m,
(values
  (1, 'tf',
   'A person''s IP address can count as personal data.', '',
   null::jsonb, 'true',
   'Correct — an IP address can locate and identify a person, so it is treated as personal data in most frameworks.'),
  (2, 'tf',
   'Removing names from a dataset always makes it fully anonymous.', '',
   null::jsonb, 'false',
   'Removing names is not enough. Remaining fields (device IDs, location, quasi-identifiers) can still re-identify people.'),
  (3, 'mc',
   'Which of these is LEAST likely to be personal data on its own?',
   '',
   $json$["A device advertising ID", "A home address", "The total number of app users this month", "A GPS location history"]$json$::jsonb,
   'The total number of app users this month',
   'An aggregate count does not relate to any one person; the others can each point to an individual.'),
  (4, 'mc',
   'Two "anonymous" columns — birth date and postcode — are released together. What is the main risk?',
   '',
   $json$["Nothing, since names were removed", "They can be combined to re-identify individuals", "The file will be too large", "The colours may render incorrectly"]$json$::jsonb,
   'They can be combined to re-identify individuals',
   'Birth date and postcode are quasi-identifiers; combined, they uniquely identify a large share of people.'),
  (5, 'mc',
   'You are unsure whether a field counts as personal data. What is the best first step?',
   '',
   $json$["Assume it is not and move on", "Ask whether it could, alone or combined, point to a real person", "Delete the entire database", "Email every user to ask"]$json$::jsonb,
   'Ask whether it could, alone or combined, point to a real person',
   'The core test is identifiability — whether the data, alone or combined, can point to an individual.'),
  (6, 'scenario',
   'Should this dataset be treated as personal data? Explain your reasoning and what you would do.',
   'Your team wants to publish a "fully anonymised" dataset of app usage: no names, but each row has a persistent device ID, timestamps, and GPS coordinates rounded to 3 decimals.',
   null::jsonb, null,
   'A strong answer recognises that persistent device IDs plus fine-grained location and timestamps are re-identifiable, so this IS personal data despite having no names. It should propose mitigations: remove or hash the device ID, coarsen location and time, apply k-anonymity or aggregation, or not publish. Weak answers call it anonymous simply because names were removed.'),
  (7, 'scenario',
   'A colleague says "it is fine to share, there are no names in it." How do you respond?',
   'A teammate wants to hand a partner company a raw export of user event logs, arguing it is safe because the name column was dropped.',
   null::jsonb, null,
   'A strong answer explains that dropping names does not anonymise data, points to remaining identifiers and quasi-identifiers, and proposes concrete safeguards (minimise fields, aggregate, a data-sharing agreement, or declining). Weak answers accept the "no names" reasoning.')
) as q("order", type, prompt, scenario, options, correct_answer, rubric)
where m.slug = 'what-counts-as-personal-data';

-- ===== Questions: Module 2 ==================================================
insert into quiz_questions (module_id, "order", type, prompt, scenario, options, correct_answer, rubric)
select id, q."order", q.type, q.prompt, q.scenario, q.options, q.correct_answer, q.rubric
from modules m,
(values
  (1, 'tf',
   'A pre-ticked "I agree" checkbox counts as valid consent.', '',
   null::jsonb, 'false',
   'Pre-ticked boxes are not valid consent — consent must be an active, informed choice.'),
  (2, 'tf',
   'Collecting extra data "just in case" you need it later is good practice.', '',
   null::jsonb, 'false',
   'This violates data minimization: unneeded data is pure added risk and liability.'),
  (3, 'mc',
   'Which best describes data minimization?',
   '',
   $json$["Collect everything now and delete later", "Collect only what the stated purpose needs", "Store data in the smallest file format", "Reduce the number of users"]$json$::jsonb,
   'Collect only what the stated purpose needs',
   'Minimization is about scope of collection — gather only what the purpose genuinely requires.'),
  (4, 'mc',
   'For consent to be valid, it must be…',
   '',
   $json$["Bundled together with all other terms", "Informed, specific, and freely given", "Given once and valid forever", "Assumed unless the user objects"]$json$::jsonb,
   'Informed, specific, and freely given',
   'These three properties are the core of valid consent in frameworks like GDPR and the PDPA.'),
  (5, 'mc',
   'A note-taking app''s signup form asks for the user''s home address. Best action?',
   '',
   $json$["Collect it because marketing asked", "Make it a required field", "Do not collect it — a note app does not need it", "Collect it but hide it from the user"]$json$::jsonb,
   'Do not collect it — a note app does not need it',
   'The core function does not require a home address, so collecting it fails minimization.'),
  (6, 'scenario',
   'How would you handle this signup form, and why?',
   'You are building a signup form for a note-taking app. Marketing asks you to also collect date of birth, phone number, and home address "in case we need them later".',
   null::jsonb, null,
   'A strong answer applies data minimization: a note-taking app needs none of those fields to function, so collecting them "just in case" is unjustified risk. It should push back, collect only what the core purpose requires, and make anything else optional with a clear purpose and real consent. Weak answers collect everything because marketing asked.'),
  (7, 'scenario',
   'What is the consent problem here, and what would you propose instead?',
   'Product wants a single "Accept all" button that covers analytics, personalised ads, and sharing data with third parties, with no other option.',
   null::jsonb, null,
   'A strong answer identifies that bundling everything behind one button is not specific or freely given consent. It should propose granular, separate opt-ins per purpose, a clear "reject non-essential" option, and plain-language explanations. Weak answers see no problem.')
) as q("order", type, prompt, scenario, options, correct_answer, rubric)
where m.slug = 'consent-and-data-minimization';
