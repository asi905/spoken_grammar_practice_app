import 'package:flutter/material.dart';
import '../models/grammar_models.dart';

final List<GrammarLevelInfo> grammarLevels = [
  GrammarLevelInfo(
    levelNumber: 1,
    titleEn: 'Foundation',
    titleBn: 'ফাউন্ডেশন',
    icon: Icons.foundation,
    color: Colors.indigo,
    completionPoints: 50,
  ),
  GrammarLevelInfo(
    levelNumber: 2,
    titleEn: 'Tense & Verb',
    titleBn: 'টেন্স ও ভার্ব',
    icon: Icons.access_time,
    color: Colors.teal,
    completionPoints: 100,
  ),
  GrammarLevelInfo(
    levelNumber: 3,
    titleEn: 'Important Grammar',
    titleBn: 'গুরুত্বপূর্ণ গ্রামার',
    icon: Icons.rule,
    color: Colors.deepOrange,
    completionPoints: 150,
  ),
  GrammarLevelInfo(
    levelNumber: 4,
    titleEn: 'Advanced Grammar',
    titleBn: 'অ্যাডভান্সড গ্রামার',
    icon: Icons.workspace_premium,
    color: Colors.deepPurple,
    completionPoints: 200,
  ),
];

final List<GrammarDay> grammarDays = [
  GrammarDay(
    levelNumber: 1,
    dayNumber: 1,
    titleEn: 'Sentence Structure',
    titleBn: 'সেন্টেন্স স্ট্রাকচার',
    icon: Icons.short_text,
    rules: [
      GrammarRule(
        titleEn: 'Sentence',
        explanationBn: 'কিছু শব্দের সমষ্টি যা একটি সম্পূর্ণ অর্থ প্রকাশ করে।',
        examples: ['I eat rice.', 'She reads books.'],
      ),
      GrammarRule(
        titleEn: 'Basic Structure: S + V + O',
        explanationBn:
            'Subject (যে কাজ করে) + Verb (কাজ) + Object (যার ওপর কাজ হয়)।',
        examples: ['I eat rice.', 'She reads books.'],
      ),
      GrammarRule(
        titleEn: 'S + V (Object ছাড়া)',
        explanationBn: 'কিছু sentence শুধু Subject + Verb দিয়েই সম্পূর্ণ হয়।',
        examples: ['I sleep.', 'Birds fly.'],
      ),
      GrammarRule(
        titleEn: 'S + V + C (Complement)',
        explanationBn: 'Complement subject সম্পর্কে তথ্য দেয়, Object নয়।',
        examples: ['I am happy.', 'He is a doctor.'],
      ),
      GrammarRule(
        titleEn: 'S + V + IO + DO',
        explanationBn:
            'Indirect Object (কাকে) + Direct Object (কী) একসাথে থাকতে পারে।',
        examples: ['I gave him a book.'],
      ),
      GrammarRule(
        titleEn: 'There + be + noun',
        explanationBn: 'কোনো কিছুর অস্তিত্ব বোঝাতে ব্যবহার হয়।',
        examples: ['There is a book on the table.'],
      ),
    ],
    questions: [
      GrammarQuestion(
        question: 'Find the object: "I eat rice."',
        options: ['I', 'eat', 'rice', 'none'],
        correctIndex: 2,
        explanationBn: '"Rice" object, কাজটা এটার উপর হচ্ছে।',
      ),
      GrammarQuestion(
        question: 'Which sentence follows S + V + C structure?',
        options: ['I eat rice.', 'He is a doctor.', 'Birds fly.', 'I sleep.'],
        correctIndex: 1,
        explanationBn:
            '"A doctor" complement, He সম্পর্কে তথ্য দিচ্ছে, object নয়।',
      ),
      GrammarQuestion(
        question: 'Choose the correct translation: "টেবিলের ওপর একটি বই আছে।"',
        options: [
          'A book is on the table.',
          'There is a book on the table.',
          'Table has a book.',
          'Book on table is there.'
        ],
        correctIndex: 1,
        explanationBn: 'অস্তিত্ব বোঝাতে "There is/are" ব্যবহার হয়।',
      ),
      GrammarQuestion(
        question: 'Which one is only S + V structure (no object)?',
        options: [
          'I eat rice.',
          'She reads books.',
          'Birds fly.',
          'He is happy.'
        ],
        correctIndex: 2,
        explanationBn: '"Birds fly" তে শুধু subject আর verb আছে, object নেই।',
      ),
      GrammarQuestion(
        question: 'Find the Indirect Object: "I gave him a book."',
        options: ['I', 'gave', 'him', 'a book'],
        correctIndex: 2,
        explanationBn:
            '"Him" indirect object (কাকে দেওয়া হলো), "a book" direct object।',
      ),
      GrammarQuestion(
        type: QuestionType.fillBlank,
        question: 'Fill in the blank: "She ___ books every night." (read)',
        correctAnswerText: 'reads',
        explanationBn:
            'Third person singular "She"-এর সাথে verb-এ s যোগ হবে, তাই "reads"।',
      ),
      GrammarQuestion(
        type: QuestionType.errorCorrection,
        question: 'Correct this sentence: "I rice eat."',
        correctAnswerText: 'I eat rice.',
        explanationBn:
            'সঠিক structure: Subject + Verb + Object, তাই "I eat rice."',
      ),
    ],
  ),
  GrammarDay(
    levelNumber: 1,
    dayNumber: 2,
    titleEn: 'Parts of Speech (8 Types)',
    titleBn: 'পার্টস অফ স্পিচ (৮ প্রকার)',
    icon: Icons.category,
    rules: [
      GrammarRule(
        titleEn: 'Noun',
        explanationBn: 'ব্যক্তি, স্থান, বস্তু, প্রাণী বা ধারণার নাম।',
        examples: ['Rahim is a student.'],
      ),
      GrammarRule(
        titleEn: 'Pronoun',
        explanationBn: 'Noun-এর পরিবর্তে ব্যবহার হয়।',
        examples: ['He reads books.'],
      ),
      GrammarRule(
        titleEn: 'Verb',
        explanationBn: 'কাজ (action) বা অবস্থা (state) বোঝায়।',
        examples: ['I eat rice.', 'He is happy.'],
      ),
      GrammarRule(
        titleEn: 'Adjective',
        explanationBn: 'Noun/Pronoun-এর গুণ, পরিমাণ, রঙ ইত্যাদি বোঝায়।',
        examples: ['He is a good student.'],
      ),
      GrammarRule(
        titleEn: 'Adverb',
        explanationBn: 'কীভাবে/কখন/কোথায়/কতটা বোঝায়।',
        examples: ['He runs quickly.', 'He is very good.'],
      ),
      GrammarRule(
        titleEn: 'Preposition',
        explanationBn: 'Noun/Pronoun-এর সাথে অন্য শব্দের সম্পর্ক বোঝায়।',
        examples: ['The book is on the table.'],
      ),
      GrammarRule(
        titleEn: 'Conjunction',
        explanationBn: 'দুইটা শব্দ/বাক্য যুক্ত করে।',
        examples: ['I like tea and coffee.'],
      ),
      GrammarRule(
        titleEn: 'Interjection',
        explanationBn: 'হঠাৎ আবেগ প্রকাশ করে।',
        examples: ['Wow! You look beautiful.'],
      ),
    ],
    questions: [
      GrammarQuestion(
        question: 'Find the Adverb: "He runs quickly."',
        options: ['He', 'runs', 'quickly', 'none'],
        correctIndex: 2,
        explanationBn: '"Quickly" বোঝাচ্ছে কীভাবে runs হচ্ছে, তাই এটা adverb।',
      ),
      GrammarQuestion(
        question: 'Adjective vs Adverb: "He is a slow driver." — "slow" is:',
        options: ['Adjective', 'Adverb', 'Noun', 'Verb'],
        correctIndex: 0,
        explanationBn: '"Slow" driver-এর quality বলছে, তাই adjective।',
      ),
      GrammarQuestion(
        question: '"He drives slowly." — "slowly" is:',
        options: ['Adjective', 'Adverb', 'Noun', 'Preposition'],
        correctIndex: 1,
        explanationBn: '"Slowly" বোঝাচ্ছে কীভাবে drives হচ্ছে, তাই adverb।',
      ),
      GrammarQuestion(
        question: 'Find the Conjunction: "He is poor but honest."',
        options: ['He', 'is', 'poor', 'but'],
        correctIndex: 3,
        explanationBn: '"But" দুইটা idea যুক্ত করছে, তাই conjunction।',
      ),
      GrammarQuestion(
        question: 'Which one is an Interjection?',
        options: ['Wow!', 'quickly', 'and', 'on'],
        correctIndex: 0,
        explanationBn: '"Wow!" হঠাৎ আবেগ প্রকাশ করছে, তাই interjection।',
      ),
      GrammarQuestion(
        question: '"I went to school because I had a class." — "because" is:',
        options: ['Preposition', 'Conjunction', 'Adverb', 'Noun'],
        correctIndex: 1,
        explanationBn: '"Because" দুইটা clause যুক্ত করছে, তাই conjunction।',
      ),
    ],
  ),
  GrammarDay(
    levelNumber: 1,
    dayNumber: 3,
    titleEn: 'Noun (Deep Dive)',
    titleBn: 'নাউন (বিস্তারিত)',
    icon: Icons.label,
    rules: [
      GrammarRule(
        titleEn: 'Proper Noun',
        explanationBn:
            'নির্দিষ্ট ব্যক্তি/স্থান/প্রতিষ্ঠানের নাম, Capital Letter দিয়ে শুরু হয়।',
        examples: ['Rahim', 'Bangladesh', 'Dhaka'],
      ),
      GrammarRule(
        titleEn: 'Common Noun',
        explanationBn: 'একই ধরনের ব্যক্তি/স্থান/বস্তুর সাধারণ নাম।',
        examples: ['boy', 'city', 'book'],
      ),
      GrammarRule(
        titleEn: 'Collective Noun',
        explanationBn:
            'অনেকগুলো ব্যক্তি/বস্তুকে একসাথে একটা group হিসেবে বোঝায়।',
        examples: ['team', 'family', 'crowd'],
      ),
      GrammarRule(
        titleEn: 'Material Noun',
        explanationBn: 'কোনো পদার্থ বা উপাদানের নাম বোঝায়।',
        examples: ['gold', 'water', 'rice'],
      ),
      GrammarRule(
        titleEn: 'Abstract Noun',
        explanationBn: 'যা দেখা/ছোঁয়া যায় না, শুধু অনুভব করা যায়।',
        examples: ['honesty', 'love', 'happiness'],
      ),
      GrammarRule(
        titleEn: 'Countable vs Uncountable',
        explanationBn:
            'Countable noun গোনা যায়; Uncountable যায় না। Uncountable-এর আগে a/an বসে না।',
        examples: ['I have two books.', 'He gave me some advice.'],
      ),
      GrammarRule(
        titleEn: 'Irregular Plural',
        explanationBn: 'কিছু noun-এর plural form নিয়ম মেনে হয় না।',
        examples: ['man → men', 'child → children', 'foot → feet'],
      ),
    ],
    questions: [
      GrammarQuestion(
        question: 'Which one is a Proper Noun?',
        options: ['boy', 'Dhaka', 'city', 'book'],
        correctIndex: 1,
        explanationBn: '"Dhaka" নির্দিষ্ট শহরের নাম, তাই proper noun।',
      ),
      GrammarQuestion(
        question: 'Which one is a Collective Noun?',
        options: ['book', 'team', 'gold', 'honesty'],
        correctIndex: 1,
        explanationBn: '"Team" একটা group বোঝাচ্ছে, তাই collective noun।',
      ),
      GrammarQuestion(
        question: 'Which one is an Uncountable Noun?',
        options: ['book', 'car', 'water', 'apple'],
        correctIndex: 2,
        explanationBn: '"Water" গোনা যায় না, তাই uncountable noun।',
      ),
      GrammarQuestion(
        question: 'Correct the sentence: "I need an advice."',
        options: [
          'I need an advice.',
          'I need some advice.',
          'I need advices.',
          'I need a advices.'
        ],
        correctIndex: 1,
        explanationBn:
            '"Advice" uncountable, তাই "an" বসে না, "some advice" সঠিক।',
      ),
      GrammarQuestion(
        question: 'What is the plural of "child"?',
        options: ['childs', 'childes', 'children', 'child'],
        correctIndex: 2,
        explanationBn: '"Child"-এর irregular plural form "children"।',
      ),
      GrammarQuestion(
        question: 'Which one is an Abstract Noun?',
        options: ['table', 'honesty', 'water', 'dog'],
        correctIndex: 1,
        explanationBn:
            '"Honesty" অনুভব করা যায় কিন্তু ছোঁয়া যায় না, তাই abstract noun।',
      ),
    ],
  ),
  GrammarDay(
    levelNumber: 1,
    dayNumber: 4,
    titleEn: 'Pronoun (Deep Dive)',
    titleBn: 'প্রোনাউন (বিস্তারিত)',
    icon: Icons.person,
    rules: [
      GrammarRule(
        titleEn: 'I vs Me',
        explanationBn:
            '"I" subject (যে কাজ করে), "me" object (যার ওপর কাজ হয়)।',
        examples: ['I study English.', 'He helped me.'],
      ),
      GrammarRule(
        titleEn: 'He/Him, She/Her, They/Them',
        explanationBn: 'Subject form কাজ করে, Object form-এর ওপর কাজ হয়।',
        examples: ['He plays football.', 'I called him.'],
      ),
      GrammarRule(
        titleEn: 'My vs Mine',
        explanationBn: '"My" সবসময় noun-এর আগে বসে, "mine" একাই বসে।',
        examples: ['This is my book.', 'This book is mine.'],
      ),
      GrammarRule(
        titleEn: 'Reflexive Pronoun',
        explanationBn:
            'Subject নিজেই নিজের ওপর কাজ করলে ব্যবহার হয়: myself, himself, themselves.',
        examples: ['I hurt myself.', 'They prepared themselves.'],
      ),
      GrammarRule(
        titleEn: 'This/That/These/Those',
        explanationBn:
            'This/That singular (কাছে/দূরে), These/Those plural (কাছে/দূরে)।',
        examples: ['This is my phone.', 'Those are my shoes.'],
      ),
    ],
    questions: [
      GrammarQuestion(
        question: 'Choose the correct pronoun: "___ am a student."',
        options: ['Me', 'I', 'My', 'Mine'],
        correctIndex: 1,
        explanationBn: 'বাক্যের শুরুতে subject হিসেবে "I" বসে।',
      ),
      GrammarQuestion(
        question: 'Choose the correct pronoun: "She called ___."',
        options: ['I', 'me', 'my', 'mine'],
        correctIndex: 1,
        explanationBn: 'Verb-এর পরে object হিসেবে "me" বসে।',
      ),
      GrammarQuestion(
        question: 'Choose the correct form: "This book is ___."',
        options: ['my', 'mine', 'me', 'I'],
        correctIndex: 1,
        explanationBn: 'Noun ছাড়া একা বসলে "mine" ব্যবহার হয়।',
      ),
      GrammarQuestion(
        question: 'Choose the correct form: "This is ___ phone."',
        options: ['mine', 'my', 'me', 'I'],
        correctIndex: 1,
        explanationBn: 'Noun-এর আগে "my" বসে।',
      ),
      GrammarQuestion(
        question: 'Choose the reflexive pronoun: "He introduced ___."',
        options: ['him', 'his', 'himself', 'he'],
        correctIndex: 2,
        explanationBn: 'নিজের উপর কাজ ফিরে আসছে, তাই "himself"।',
      ),
      GrammarQuestion(
        question: 'Choose correctly: "___ is my brother."',
        options: ['Him', 'He', 'His', 'Himself'],
        correctIndex: 1,
        explanationBn: 'Subject হিসেবে "He" ব্যবহার হবে।',
      ),
    ],
  ),
  GrammarDay(
    levelNumber: 1,
    dayNumber: 5,
    titleEn: 'Verb (Deep Dive)',
    titleBn: 'ভার্ব (বিস্তারিত)',
    icon: Icons.directions_run,
    rules: [
      GrammarRule(
        titleEn: 'Main Verb',
        explanationBn: 'বাক্যের মূল কাজ বা অবস্থা প্রকাশ করে।',
        examples: ['I play football.', 'He is happy.'],
      ),
      GrammarRule(
        titleEn: 'Helping/Auxiliary Verb',
        explanationBn:
            'Main verb-কে সাহায্য করে: am/is/are, have/has/had, do/does/did.',
        examples: ['She is reading.', 'They have finished.'],
      ),
      GrammarRule(
        titleEn: 'Verb-এর 5 Forms',
        explanationBn:
            'V1 (base), V2 (past), V3 (past participle), V4 (-ing), V5 (s/es)।',
        examples: ['go – went – gone – going – goes'],
      ),
      GrammarRule(
        titleEn: 'I/You/We/They → V1, He/She/It → V5',
        explanationBn: 'Present Simple-এ subject অনুযায়ী verb form বদলায়।',
        examples: ['I play.', 'He plays.'],
      ),
      GrammarRule(
        titleEn: 'Transitive vs Intransitive',
        explanationBn:
            'Transitive verb-এর পরে object লাগে, Intransitive verb-এর পরে লাগে না।',
        examples: ['I eat rice. (Transitive)', 'Birds fly. (Intransitive)'],
      ),
      GrammarRule(
        titleEn: 'Regular vs Irregular Verb',
        explanationBn:
            'Regular verb-এর past form -ed যোগ হয়ে হয়; Irregular verb নিয়ম মানে না।',
        examples: ['play → played (Regular)', 'go → went (Irregular)'],
      ),
    ],
    questions: [
      GrammarQuestion(
        question: 'Choose the correct sentence:',
        options: [
          'He go to school.',
          'He goes to school.',
          'He going to school.',
          'He gone to school.'
        ],
        correctIndex: 1,
        explanationBn:
            'Subject "He" third person singular, তাই verb-এ s/es (V5) যোগ হবে।',
      ),
      GrammarQuestion(
        question: 'Did-এর পরে কোন form বসে?',
        options: [
          'I did not went there.',
          'I did not go there.',
          'I did not going there.',
          'I did not goes there.'
        ],
        correctIndex: 1,
        explanationBn: '"Did" এর পরে সবসময় V1 (base form) বসে।',
      ),
      GrammarQuestion(
        question: 'Modal verb-এর পরে কোন form বসে?',
        options: [
          'He can speaks English.',
          'He can speak English.',
          'He can spoken English.',
          'He can speaking English.'
        ],
        correctIndex: 1,
        explanationBn: 'Modal verb-এর পরে সবসময় V1 বসে।',
      ),
      GrammarQuestion(
        question: 'Find the helping verb: "They have finished their work."',
        options: ['They', 'have', 'finished', 'work'],
        correctIndex: 1,
        explanationBn: '"Have" auxiliary verb, "finished"-কে সাহায্য করছে।',
      ),
      GrammarQuestion(
        question: '"I eat rice." — এখানে verb কী ধরনের?',
        options: ['Transitive', 'Intransitive', 'Modal', 'Auxiliary'],
        correctIndex: 0,
        explanationBn:
            '"Eat"-এর পরে object "rice" আছে, তাই এটা transitive verb।',
      ),
      GrammarQuestion(
        question: 'What is the past form (V2) of "eat"?',
        options: ['eats', 'eating', 'ate', 'eaten'],
        correctIndex: 2,
        explanationBn: '"Eat"-এর past form (V2) হলো "ate"।',
      ),
    ],
  ),
  GrammarDay(
    levelNumber: 1,
    dayNumber: 6,
    titleEn: 'Present Simple Tense',
    titleBn: 'প্রেজেন্ট সিম্পল টেন্স',
    icon: Icons.today,
    rules: [
      GrammarRule(
        titleEn: 'কখন ব্যবহার হয়',
        explanationBn: 'অভ্যাস/নিয়মিত কাজ, সাধারণ সত্য, পছন্দ-অপছন্দ বোঝাতে।',
        examples: [
          'I go to university every day.',
          'The sun rises in the east.'
        ],
      ),
      GrammarRule(
        titleEn: 'Positive Structure',
        explanationBn: 'I/You/We/They + V1; He/She/It + V5.',
        examples: ['I play football.', 'He plays football.'],
      ),
      GrammarRule(
        titleEn: 'Negative Structure',
        explanationBn:
            'I/You/We/They + don\'t + V1; He/She/It + doesn\'t + V1.',
        examples: ["I don't like coffee.", "He doesn't play football."],
      ),
      GrammarRule(
        titleEn: 'Question Structure',
        explanationBn: 'Do/Does + Subject + V1?',
        examples: ['Do you like coffee?', 'Does he play football?'],
      ),
      GrammarRule(
        titleEn: 'WH-Question',
        explanationBn: 'WH + do/does + Subject + V1...?',
        examples: ['Where do you live?', 'Who plays football?'],
      ),
      GrammarRule(
        titleEn: 'Signal Words',
        explanationBn: 'always, usually, often, sometimes, never, every day.',
        examples: ['I always wake up early.', 'She usually drinks tea.'],
      ),
    ],
    questions: [
      GrammarQuestion(
        question: 'Choose the correct sentence:',
        options: [
          'She go to school.',
          'She goes to school.',
          'She going to school.',
          'She gone to school.'
        ],
        correctIndex: 1,
        explanationBn:
            'Third person singular "She"-এর সাথে V5 form "goes" হবে।',
      ),
      GrammarQuestion(
        question: 'Choose the correct negative: "He ___ like coffee."',
        options: ["don't", "doesn't", 'not', 'no'],
        correctIndex: 1,
        explanationBn:
            'Third person singular "He"-এর সাথে "doesn\'t" ব্যবহার হবে।',
      ),
      GrammarQuestion(
        question: 'Choose the correct sentence:',
        options: [
          'Does he plays football?',
          'Does he play football?',
          'Do he play football?',
          'Does he played football?'
        ],
        correctIndex: 1,
        explanationBn: '"Does" থাকলে verb-এ s/es যোগ হবে না, V1 বসবে।',
      ),
      GrammarQuestion(
        question: 'Choose the correct WH-question: "___ do you live?"',
        options: ['What', 'Where', 'When', 'Who'],
        correctIndex: 1,
        explanationBn: 'জায়গা জানতে "Where" ব্যবহার হয়।',
      ),
      GrammarQuestion(
        question:
            'Choose the correct short answer: "Does she like tea?" — "Yes, ___."',
        options: ['she does', 'she do', 'she is', 'she has'],
        correctIndex: 0,
        explanationBn:
            'Does দিয়ে প্রশ্ন হলে short answer-এও "does" ব্যবহার হয়।',
      ),
      GrammarQuestion(
        question: 'Choose the correct sentence with "study" for "he":',
        options: [
          'He studys English.',
          'He studies English.',
          'He studying English.',
          'He study English.'
        ],
        correctIndex: 1,
        explanationBn: 'Consonant + y হলে y → ies হয়, তাই "studies"।',
      ),
    ],
  ),
  GrammarDay(
    levelNumber: 1,
    dayNumber: 7,
    titleEn: 'Present Continuous Tense',
    titleBn: 'প্রেজেন্ট কন্টিনিউয়াস টেন্স',
    icon: Icons.autorenew,
    rules: [
      GrammarRule(
        titleEn: 'কী বোঝায়',
        explanationBn: 'এই মুহূর্তে চলছে এমন কাজ বোঝায়।',
        examples: ['I am reading a book.', 'They are playing football.'],
      ),
      GrammarRule(
        titleEn: 'Positive Structure',
        explanationBn:
            'Subject + am/is/are + V-ing। I → am; He/She/It → is; You/We/They → are.',
        examples: ['I am learning English.', 'He is playing football.'],
      ),
      GrammarRule(
        titleEn: 'Negative Structure',
        explanationBn: 'Subject + am/is/are + not + V-ing.',
        examples: ['I am not studying now.', "He isn't sleeping."],
      ),
      GrammarRule(
        titleEn: 'Question Structure',
        explanationBn: 'Am/Is/Are + Subject + V-ing?',
        examples: ['Are you learning English?', 'Is he playing football?'],
      ),
      GrammarRule(
        titleEn: 'V-ing বানানোর নিয়ম',
        explanationBn:
            'সাধারণত +ing; শেষে e থাকলে e বাদ দিয়ে +ing; short vowel+consonant হলে consonant double হয়।',
        examples: ['play → playing', 'make → making', 'run → running'],
      ),
      GrammarRule(
        titleEn: 'Present Simple vs Continuous',
        explanationBn: 'Simple = অভ্যাস/নিয়মিত কাজ; Continuous = এখন চলছে।',
        examples: [
          'I play football every day. (habit)',
          'I am playing football now.'
        ],
      ),
    ],
    questions: [
      GrammarQuestion(
        question: 'Choose the correct sentence:',
        options: [
          'She cooking dinner.',
          'She is cooking dinner.',
          'She are cooking dinner.',
          'She cook dinner now.'
        ],
        correctIndex: 1,
        explanationBn:
            'Singular subject "She"-এর সাথে "is" বসে, verb-এ -ing যোগ হবে।',
      ),
      GrammarQuestion(
        question: 'Choose the correct V-ing form of "write":',
        options: ['writeing', 'writting', 'writing', 'writes'],
        correctIndex: 2,
        explanationBn: 'শেষে "e" থাকলে বাদ দিয়ে +ing হয়, তাই "writing"।',
      ),
      GrammarQuestion(
        question: 'Choose the correct V-ing form of "run":',
        options: ['runing', 'running', 'runeing', 'runs'],
        correctIndex: 1,
        explanationBn:
            'Short vowel + consonant হলে consonant double হয়, তাই "running"।',
      ),
      GrammarQuestion(
        question: 'Which sentence shows Present Continuous?',
        options: [
          'She reads books every night.',
          'She is reading a book now.',
          'She read a book.',
          'She has read a book.'
        ],
        correctIndex: 1,
        explanationBn: '"Now" দিয়ে এখন চলছে বোঝাচ্ছে, তাই Present Continuous।',
      ),
      GrammarQuestion(
        question: 'Choose the correct question: "___ you studying now?"',
        options: ['Do', 'Does', 'Are', 'Is'],
        correctIndex: 2,
        explanationBn: 'Subject "you"-এর সাথে "Are" ব্যবহার হয়।',
      ),
      GrammarQuestion(
        question:
            'Choose the correct negative short form: "He is not sleeping."',
        options: [
          "He don't sleeping.",
          "He isn't sleeping.",
          "He doesn't sleeping.",
          "He not sleeping."
        ],
        correctIndex: 1,
        explanationBn: '"Is not" এর short form "isn\'t"।',
      ),
    ],
  ),
  GrammarDay(
    levelNumber: 1,
    dayNumber: 8,
    titleEn: 'Present Perfect Tense',
    titleBn: 'প্রেজেন্ট পারফেক্ট টেন্স',
    icon: Icons.check_circle_outline,
    rules: [
      GrammarRule(
        titleEn: 'কী বোঝায়',
        explanationBn:
            'অতীতে ঘটেছে কিন্তু ফলাফল/সম্পর্ক বর্তমানে আছে, বা কাজ সম্পন্ন হয়েছে।',
        examples: ['I have eaten rice.', 'She has finished her work.'],
      ),
      GrammarRule(
        titleEn: 'Positive Structure',
        explanationBn:
            'Subject + have/has + V3। I/You/We/They → have; He/She/It → has.',
        examples: ['I have finished my work.', 'He has finished his work.'],
      ),
      GrammarRule(
        titleEn: 'Negative Structure',
        explanationBn: 'Subject + have/has + not + V3.',
        examples: ["I haven't seen him.", "She hasn't eaten yet."],
      ),
      GrammarRule(
        titleEn: 'Question Structure',
        explanationBn: 'Have/Has + Subject + V3?',
        examples: ['Have you eaten?', 'Has he finished?'],
      ),
      GrammarRule(
        titleEn: 'Just / Already / Yet',
        explanationBn:
            '"Just" এইমাত্র, "already" ইতোমধ্যে, "yet" এখনও (negative/question-এ)।',
        examples: ['I have just finished my work.', "I haven't finished yet."],
      ),
      GrammarRule(
        titleEn: 'Ever / Never',
        explanationBn: '"Ever" কখনো (question-এ), "never" কখনোই না।',
        examples: [
          "Have you ever visited Cox's Bazar?",
          'I have never visited London.'
        ],
      ),
      GrammarRule(
        titleEn: 'Since / For',
        explanationBn: '"Since" শুরুর সময় বোঝায়, "for" কতক্ষণ ধরে বোঝায়।',
        examples: [
          'I have lived here since 2020.',
          'I have lived here for five years.'
        ],
      ),
    ],
    questions: [
      GrammarQuestion(
        question: 'Choose the correct sentence:',
        options: [
          'I have ate rice.',
          'I have eaten rice.',
          'I have eat rice.',
          'I have eating rice.'
        ],
        correctIndex: 1,
        explanationBn: '"Have" এর পরে V3 বসে, "eat"-এর V3 "eaten"।',
      ),
      GrammarQuestion(
        question: 'Choose the correct sentence:',
        options: [
          'She has went home.',
          'She has go home.',
          'She has gone home.',
          'She has going home.'
        ],
        correctIndex: 2,
        explanationBn: '"Go"-এর V3 হলো "gone"।',
      ),
      GrammarQuestion(
        question:
            'Choose the correct word: "I have ___ finished my work." (এইমাত্র)',
        options: ['already', 'just', 'yet', 'ever'],
        correctIndex: 1,
        explanationBn: '"Just" মানে এইমাত্র, সদ্য হওয়া কাজ বোঝায়।',
      ),
      GrammarQuestion(
        question:
            'Choose the correct sentence: "আমি ২০২০ সাল থেকে এখানে থাকি।"',
        options: [
          'I have lived here for 2020.',
          'I have lived here since 2020.',
          'I live here since 2020.',
          'I have live here since 2020.'
        ],
        correctIndex: 1,
        explanationBn: 'নির্দিষ্ট শুরুর সময় বোঝাতে "since" ব্যবহার হয়।',
      ),
      GrammarQuestion(
        question: 'Choose the correct sentence: "___ you ever visited Dhaka?"',
        options: ['Do', 'Have', 'Are', 'Has'],
        correctIndex: 1,
        explanationBn:
            'Present Perfect question-এ "Have you ever...?" ব্যবহার হয়।',
      ),
      GrammarQuestion(
        question:
            'Choose the correct negative: "I haven\'t finished my work ___."',
        options: ['just', 'already', 'yet', 'ever'],
        correctIndex: 2,
        explanationBn: '"Yet" সাধারণত negative sentence-এর শেষে বসে।',
      ),
    ],
  ),
  GrammarDay(
    levelNumber: 1,
    dayNumber: 9,
    titleEn: 'Present Perfect Continuous Tense',
    titleBn: 'প্রেজেন্ট পারফেক্ট কন্টিনিউয়াস টেন্স',
    icon: Icons.hourglass_bottom,
    rules: [
      GrammarRule(
        titleEn: 'কী বোঝায়',
        explanationBn:
            'অতীতে শুরু হয়ে এখনও চলছে, বা কতক্ষণ ধরে চলছে তা বোঝায়।',
        examples: ['I have been studying English for two hours.'],
      ),
      GrammarRule(
        titleEn: 'Positive Structure',
        explanationBn:
            'Subject + have/has + been + V-ing। I/You/We/They → have been; He/She/It → has been.',
        examples: [
          'I have been learning English.',
          'She has been cooking for an hour.'
        ],
      ),
      GrammarRule(
        titleEn: 'Negative Structure',
        explanationBn: 'Subject + have/has + not + been + V-ing.',
        examples: ["I haven't been studying.", "She hasn't been working."],
      ),
      GrammarRule(
        titleEn: 'Question Structure',
        explanationBn: 'Have/Has + Subject + been + V-ing?',
        examples: ['Have you been studying?', 'Has he been sleeping?'],
      ),
      GrammarRule(
        titleEn: 'Since vs For',
        explanationBn:
            '"Since" শুরুর নির্দিষ্ট সময় বোঝায়, "for" মোট সময়কাল বোঝায়।',
        examples: ['since 2020 (শুরুর সময়)', 'for two hours (কতক্ষণ ধরে)'],
      ),
    ],
    questions: [
      GrammarQuestion(
        question: 'Choose the correct sentence:',
        options: [
          'I have studying English.',
          'I have been studying English.',
          'I has been studying English.',
          'I am been studying English.'
        ],
        correctIndex: 1,
        explanationBn: '"I"-এর সাথে "have been" বসে।',
      ),
      GrammarQuestion(
        question: 'Choose the correct sentence:',
        options: [
          'She have been working here.',
          'She has been working here.',
          'She has being working here.',
          'She has been work here.'
        ],
        correctIndex: 1,
        explanationBn: 'Third person singular "She"-এর সাথে "has been" বসে।',
      ),
      GrammarQuestion(
        question:
            'Choose the correct word: "I have been studying ___ two hours."',
        options: ['since', 'for', 'from', 'at'],
        correctIndex: 1,
        explanationBn: 'সময়কাল বোঝাতে "for" ব্যবহার হয়।',
      ),
      GrammarQuestion(
        question: 'Choose the correct word: "It has been raining ___ morning."',
        options: ['since', 'for', 'from', 'in'],
        correctIndex: 0,
        explanationBn: 'শুরুর সময় বোঝাতে "since" ব্যবহার হয়।',
      ),
      GrammarQuestion(
        question: 'Choose the correct question:',
        options: [
          'Have you been study?',
          'Have you been studying?',
          'Do you been studying?',
          'Are you been studying?'
        ],
        correctIndex: 1,
        explanationBn: 'Structure: Have/Has + Subject + been + V-ing?',
      ),
    ],
  ),
  GrammarDay(
    levelNumber: 1,
    dayNumber: 10,
    titleEn: 'Present Tense Master Revision + Test',
    titleBn: 'প্রেজেন্ট টেন্স মাস্টার রিভিশন + টেস্ট',
    icon: Icons.emoji_events,
    rules: [
      GrammarRule(
        titleEn: 'Present Simple',
        explanationBn: 'অভ্যাস/নিয়মিত কাজ। Structure: Subject + V1/V5.',
        examples: ['I play football every day.'],
      ),
      GrammarRule(
        titleEn: 'Present Continuous',
        explanationBn: 'এখন চলছে। Structure: Subject + am/is/are + V-ing.',
        examples: ['I am playing football now.'],
      ),
      GrammarRule(
        titleEn: 'Present Perfect',
        explanationBn:
            'কাজ সম্পন্ন, ফলাফল বর্তমানে আছে। Structure: Subject + have/has + V3.',
        examples: ['I have finished my work.'],
      ),
      GrammarRule(
        titleEn: 'Present Perfect Continuous',
        explanationBn:
            'অতীতে শুরু হয়ে এখনও চলছে। Structure: Subject + have/has + been + V-ing.',
        examples: ['I have been studying for two hours.'],
      ),
    ],
    questions: [
      GrammarQuestion(
        question: 'Which tense: "I play football every day."?',
        options: [
          'Present Simple',
          'Present Continuous',
          'Present Perfect',
          'Present Perfect Continuous'
        ],
        correctIndex: 0,
        explanationBn: 'নিয়মিত অভ্যাস বোঝাচ্ছে, তাই Present Simple।',
      ),
      GrammarQuestion(
        question: 'Which tense: "I am playing football now."?',
        options: [
          'Present Simple',
          'Present Continuous',
          'Present Perfect',
          'Present Perfect Continuous'
        ],
        correctIndex: 1,
        explanationBn: '"Now" দিয়ে এখন চলছে বোঝাচ্ছে।',
      ),
      GrammarQuestion(
        question: 'Which tense: "I have finished my homework."?',
        options: [
          'Present Simple',
          'Present Continuous',
          'Present Perfect',
          'Present Perfect Continuous'
        ],
        correctIndex: 2,
        explanationBn: 'কাজ সম্পন্ন, ফলাফল বর্তমানে আছে।',
      ),
      GrammarQuestion(
        question: 'Which tense: "I have been studying since morning."?',
        options: [
          'Present Simple',
          'Present Continuous',
          'Present Perfect',
          'Present Perfect Continuous'
        ],
        correctIndex: 3,
        explanationBn: 'অতীতে শুরু হয়ে এখনও চলছে।',
      ),
      GrammarQuestion(
        question: 'Choose the correct sentence: "She ___ her work."',
        options: ['finish', 'finishes', 'has finished', 'is finishing'],
        correctIndex: 2,
        explanationBn: 'Present Perfect-এ "has + V3" বসে।',
      ),
      GrammarQuestion(
        question: 'Choose the correct sentence: "They ___ football right now."',
        options: ['play', 'plays', 'are playing', 'have played'],
        correctIndex: 2,
        explanationBn: '"Right now" দিয়ে এখন চলছে বোঝাচ্ছে।',
      ),
      GrammarQuestion(
        question:
            'Choose the correct sentence: "He ___ in Dhaka for five years."',
        options: ['live', 'lives', 'has been living', 'is living'],
        correctIndex: 2,
        explanationBn: '"For five years" duration বোঝাচ্ছে।',
      ),
    ],
  ),
];
