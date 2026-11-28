class_name Shakhsiat
extends Node
## مغز بوقی — موتور شخصیت محلی ماشین‌ها (کاملاً آفلاین، داخل خود بازی)
## هر ماشین شخصیت و صدای مخصوص خودش را دارد؛ صداها همان لحظه ساخته می‌شوند
## و حبابِ گفتار روی سر ماشین باز می‌شود. بوقی شیطونِ محله است و سیستم
## همیشه طرف او را می‌گیرد (بوست مخفی!).

const COL_BG := Color(0.99, 0.965, 0.88, 0.97)
const COL_LINE := Color(0.29, 0.216, 0.157)
const COL_TXT := Color(0.22, 0.14, 0.07)

# صدای هر ماشین: pitch=زیر و بمی، tone=جیغی/بمی بودن رگه صدا، rate=سرعت هجا
# صداها لاله‌زبانِ ماشین‌هاست — مثل انیمیشن‌های معروف ماشین‌ها هر کدام لهجه خودشان را دارند
const SHAKHSIATHA := {
        "helia": {
                "lakeb": "هلیا",
                "sedasar": {"zomz": 235.0, "javse": 0.62, "nerkh": 10.5, "larz": 0.12},
                "harfha": {
                        "idle": ["آماده‌ای؟ ما می‌بریم.", "خیابان‌های تهران امشب بیدارند.", "چرخ جلو رو نگه دار، بقیه‌ش با من."],
                        "select": ["هلیا در مسیره.", "کمربند ببند."],
                        "buy": [],
                        "poor": [],
                        "upgrade": [],
                        "go": ["بریم!", "نورها سبز!"],
                        "nitro": ["نیترو باز شد!", "حالا ببین و یاد بگیر!"],
                        "hit": ["آخ! بغل نگه دار!", "خودتم آمدی؟!"],
                        "win": ["اول. همیشه.", "خیابون مال ما بود، هست و خواهد بود."],
                        "lose": ["اشکال نداره. دوباره.", "دفعه بعد حساب می‌کنم."],
                        "boost": ["نیترو پر شد، بزن!"],
                },
        },
        "boghi": {
                "lakeb": "بوقیِ شیطون",
                "sedasar": {"zomz": 330.0, "javse": 0.75, "nerkh": 11.0, "larz": 0.18},
                "harfha": {
                        "idle": ["منو انتخاب کن! قول می‌دم بترکونیم!", "هی! یه مسابقه‌ی کوچولو داریم؟", "بوق بزن تا همه بدونن کی خوشگله‌!", "چهارچرخمو دیدی؟ براقه، نه؟"],
                        "select": ["آره! بالاخره فهمیدی من بهترینم!", "بوقی تو راهه، جا خالی کن!"],
                        "buy": [],
                        "poor": ["پول صرفه‌جویی کن، بعد بگو بوقی!"],
                        "upgrade": ["اوه! خفن‌تر از قبل شدم!"],
                        "go": ["برق پیش! بوقی تو راهه!"],
                        "nitro": ["بوووووق! آتیشه آتیشه!"],
                        "hit": ["اوخ! مواظب باش دیگه!", "ای! دوبومو زدی!"],
                        "win": ["به من می‌گن قهرمان محل!"],
                        "lose": ["اشکال نداره، بوقی که همیشه هست!"],
                        "boost": ["اینم هدیه‌ی بوقی! نیترو پر شد!", "سیستم با منه، نمی‌دونی؟! نیترو بزن!"],
                },
        },
        "boghi_yellow": {
                "lakeb": "بوقیِ آفتابی",
                "sedasar": {"zomz": 355.0, "javse": 0.65, "nerkh": 11.5, "larz": 0.16},
                "harfha": {
                        "idle": ["آفتاب که می‌زنه، من راه می‌افتم!", "داداش بوقیم — ولی زردِ آفتاب‌خورده!", "زردم چون سریع‌ترینم!"],
                        "select": ["با آفتابِ محل رفاقت کن!", "یزرد! بریم که دنیا بچرخه!"],
                        "buy": ["خریدی منو؟ بهترین انتخاب عمرت!"],
                        "poor": ["یه ذره سکه جمع کن، می‌ترکونی!"],
                        "upgrade": ["حالا شدم خورشیدِ جاده!"],
                        "go": ["طلوع کردیم! بریم!"],
                        "nitro": ["آفتابِ داغ! کنار بکش!"],
                        "hit": ["اوخ! آفتابه رو خراشوندی!"],
                        "win": ["درخشیدم، نه؟!"],
                        "lose": ["فردا دوباره می‌تابم!"],
                },
        },
        "tiba": {
                "lakeb": "تیبای چابک",
                "sedasar": {"zomz": 440.0, "javse": 0.55, "nerkh": 13.0, "larz": 0.2},
                "harfha": {
                        "idle": ["سبکم مثل پر کبوتر!", "پرش‌های دقیق کار منمه!", "یه دور بزنیم؟ من تمیز می‌پرم!"],
                        "select": ["تووووپ! تکون نمی‌خورم از دستت!"],
                        "buy": ["چسبیدی بهم؟ خوش اومدی!"],
                        "poor": ["آخ، سکه‌هات کمه!"],
                        "upgrade": ["نرم‌تر از قبل شدم!"],
                        "go": ["پرواز کن! نه، ببخشید، بریم!"],
                        "nitro": ["باد رفت رو من!"],
                        "hit": ["هیس! مواظب فرم باش!"],
                        "win": ["دقیق و خوشگل! مثل خودم!"],
                        "lose": ["دفعه بعد نرم‌تر می‌پرم!"],
                },
        },
        "pride": {
                "lakeb": "پرایدِ جیغ",
                "sedasar": {"zomz": 400.0, "javse": 0.85, "nerkh": 12.0, "larz": 0.22},
                "harfha": {
                        "idle": ["استریک منو دیدی؟ مسابقه‌ایم من!", "جیغ بزن تا صدا بگیره!", "قرمزم چون آتیشم!"],
                        "select": ["بخیه بزن، الان می‌پروونمت!"],
                        "buy": ["برنده شدی که منو گرفتی!"],
                        "poor": ["من گرونم، ولی می‌ارزه!"],
                        "upgrade": ["الان صدای اگزوزم فرق داره!"],
                        "go": ["جیغوووو! رفتیم!"],
                        "nitro": ["هووووت! آتیشِ قرمز!"],
                        "hit": ["ای بابا! اسپویلرمو!"],
                        "win": ["گفتم که! مسابقه‌ایم!"],
                        "lose": ["جیغم دراومد به خاطر باخت!"],
                },
        },
        "pejo": {
                "lakeb": "پژوی فرمان‌رو",
                "sedasar": {"zomz": 330.0, "javse": 0.5, "nerkh": 10.0, "larz": 0.12},
                "harfha": {
                        "idle": ["تعادل، رمز من است.", "نقره‌ایم چون کلاس دارم.", "فرمان دستمه، خیالت راحت."],
                        "select": ["انتخابِ یک حرفه‌ای.", "با من، خیابان مال توئه."],
                        "buy": ["سرمایه‌گذاری خوبی بود."],
                        "poor": ["من می‌ارزم، جمع کن سکه‌هات."],
                        "upgrade": ["حالا حرفه‌ایِ حرفه‌ای‌ها."],
                        "go": ["آرام، مطمئن، اول."],
                        "nitro": ["قدرتِ فرانسوی!"],
                        "hit": ["کلاسم اجازه نمی‌داد، ولی بگذریم."],
                        "win": ["همیشه اول، به جز دومی."],
                        "lose": ["حتی قهرمان‌ها هم می‌بازند."],
                },
        },
        "samand": {
                "lakeb": "سمندِ پیرِ خردمند",
                "sedasar": {"zomz": 200.0, "javse": 0.35, "nerkh": 7.0, "larz": 0.1},
                "harfha": {
                        "idle": ["جوان‌مرد، من سال‌هاست این جاده‌ها را می‌بینم...", "محکم مثل کوه، آرام مثل باران.", "پشت من وایسا، هیچی اتفاق نمی‌افته."],
                        "select": ["پشت من وایسا پسرم، امن‌ترین جا دنیاست."],
                        "buy": ["خریدِ عاقلانه‌ای بود، آفرین."],
                        "poor": ["عجله نکن، سکه مثل رود جمع می‌شه."],
                        "upgrade": ["حتی پیرترها هم دوست دارن خفن باشن!"],
                        "go": ["بسم‌الله. آروم و مطمئن."],
                        "nitro": ["در جوانیم یادم رفت سرعت این‌قدر خوبه!"],
                        "hit": ["خس دیدم؟ کوله‌پشتم پاره نشه فقط!"],
                        "win": ["تجربه که باشد، پیروزی هم هست."],
                        "lose": ["جوانمردی این است که بلند شی دوباره."],
                },
        },
        "dena": {
                "lakeb": "دنای آرام",
                "sedasar": {"zomz": 255.0, "javse": 0.45, "nerkh": 9.0, "larz": 0.1},
                "harfha": {
                        "idle": ["شکوه، آرامش، دنا.", "جاده‌های بزرگ به سدان بزرگ نیاز دارند.", "سفیدم چون صلح‌آمیزم."],
                        "select": ["تشریف بیارید جلو، سرنشینِ محترم!"],
                        "buy": ["انتخابی باوقار بود."],
                        "poor": ["من لیاقت سکه‌های بیشتری هستم."],
                        "upgrade": ["حالا باوقارتر از همیشه."],
                        "go": ["با اجازه‌ی همه، حرکت."],
                        "nitro": ["شکوهِ سرعت!"],
                        "hit": ["خب... مودبانه بگم: مواظب باشید!"],
                        "win": ["باوقارانه برنده شدم."],
                        "lose": ["منحنیِ زندگی، دوباره برمی‌گردد."],
                },
        },
        "nissan": {
                "lakeb": "نیسانِ آسفالت‌خور",
                "sedasar": {"zomz": 150.0, "javse": 0.9, "nerkh": 6.5, "larz": 0.08},
                "harfha": {
                        "idle": ["هوم. من وانت نیسانم. بارِ سنگین؟ بازیچه.", "قرمزم چون آجر قرمز، مثل من سخت.", "سرعتم کمه؟ کل لودری رو زمین دارم."],
                        "select": ["سوار شو. لرزیدی؟ عادیه."],
                        "buy": ["هوم. خرید خوبی بود."],
                        "poor": ["سکه بیار. بعد بیا."],
                        "upgrade": ["هوم. حالا محکم‌ترم."],
                        "go": ["رفتیم. سکوت کن، کار دارم."],
                        "nitro": ["هوووم. غرشِ وانت!"],
                        "hit": ["گلگیرم خراش برد... خیالت راحت."],
                        "win": ["هوم. طبیعتاً."],
                        "lose": ["مانع بود. قضیه همین بود."],
                },
        },
        "pejo_race": {
                "lakeb": "پژوی پیست",
                "sedasar": {"zomz": 385.0, "javse": 0.8, "nerkh": 12.5, "larz": 0.2},
                "harfha": {
                        "idle": ["قرمز آتشین با استریک سفید — عاشق پیستم!", "کلاچ و گاز، کل زندگی من!", "پیست خونه‌ی دوممه!"],
                        "select": ["ایول! حالا یه مسابقه واقعیه!"],
                        "buy": ["به تیم مسابقه خوش اومدی!"],
                        "poor": ["پیست منتظر می‌مونه... ولی من نه!"],
                        "upgrade": ["حالا تایپ R شدم!"],
                        "go": ["چراغ سبز! گاز تا ته!"],
                        "nitro": ["فول بوست! هیسسسس!"],
                        "hit": ["رینگم! رینگ مسابقه‌ایم!"],
                        "win": ["جایزه اول، روی سکو!"],
                        "lose": ["پیست یادمه... انتقام می‌گیرم!"],
                },
        },
        "shahin": {
                "lakeb": "شاهینِ شب",
                "sedasar": {"zomz": 225.0, "javse": 0.7, "nerkh": 8.5, "larz": 0.12},
                "harfha": {
                        "idle": ["شب که بشه، خیابون مال منه.", "مشکیِ طلایی‌خط — شاهِ شب‌های تهران.", "صدای منو شنیدی؟ اون بود که چراغا رو جا گذاشت."],
                        "select": ["خوبه. شب امشب جالبه."],
                        "buy": ["سلیقه داری. قبول شد."],
                        "poor": ["من طلایی‌خطتم، قیمت هم دارم."],
                        "upgrade": ["حالا شبا ترکش خوردن از من."],
                        "go": ["چراغا خاموش... شروع شد."],
                        "nitro": ["شبِ تندِ بی‌رحم!"],
                        "hit": ["خط طلاییمو دیدی؟ دست نزن بهش."],
                        "win": ["معلوم بود. شاه همیشه می‌بره."],
                        "lose": ["شب هنوز تموم نشده..."],
                },
        },
        "quick": {
                "lakeb": "کوییکِ جیغ‌جوان",
                "sedasar": {"zomz": 470.0, "javse": 0.75, "nerkh": 14.0, "larz": 0.25},
                "harfha": {
                        "idle": ["نارنجیم! جیغ‌ترین رنگِ دنیا!", "پرش‌های بلند؟ تخصص منم!", "آخیش! بالاخره گشادمت!"],
                        "select": ["یِیِس! بزن بریم هوووا!"],
                        "buy": ["خریدی منو؟ بهترین کار زندگیت!"],
                        "poor": ["وایسا وایسا، سکه بیار بعد بیا!"],
                        "upgrade": ["حالا از تو خودم سریع‌ترم!"],
                        "go": ["سریع‌ سریع‌ سریع‌! رفتیم!"],
                        "nitro": ["وووووووووووووووو!"],
                        "hit": ["اووخ! لاستیلام!"],
                        "win": ["معلومه که بردم! سریع بودم!"],
                        "lose": ["دفعه بعد، سریع‌ترِ سریع‌تر!"],
                },
        },
        "dena_race": {
                "lakeb": "دنای قهرمان",
                "sedasar": {"zomz": 270.0, "javse": 0.65, "nerkh": 9.5, "larz": 0.14},
                "harfha": {
                        "idle": ["سدانِ ملی با لباس استریک — غرورِ پیست!", "قهرمان‌ها آرام حرف می‌زنند، سریع می‌روند.", "سکو؟ خونه‌ی دوممه."],
                        "select": ["با من، فقط جای اول."],
                        "buy": ["به تیم قهرمان‌ها خوش آمدی."],
                        "poor": ["غرور من گرون‌تر از این حرفاست."],
                        "upgrade": ["حالا قهرمانِ قهرمان‌ها."],
                        "go": ["با اجازه‌ی سکو، حرکت!"],
                        "nitro": ["غرورِ ملی، سرعتِ جهانی!"],
                        "hit": ["استریکم! آخ، استریکم!"],
                        "win": ["طلای دیگر به کارنامه‌ام اضافه شد."],
                        "lose": ["قهرمان واقعی از باخت درس می‌گیرد."],
                },
        },
        "pride_blue": {
                "lakeb": "موج آبی",
                "sedasar": {"zomz": 390.0, "javse": 0.8, "nerkh": 12.0, "larz": 0.2},
                "harfha": {
                        "idle": ["موج آبی پیست منم! بال بزرگم رو دیدی؟", "آبیِ اقیانوسی با استریک سفید!", "بال عقبم زمین رو نگه می‌داره، نه آدمو!"],
                        "select": ["سوار موج شو!"],
                        "buy": ["به باشگاه موج‌سوارها خوش اومدی!"],
                        "poor": ["موج گرونه داداش!"],
                        "upgrade": ["حالا موجم طوفانیه!"],
                        "go": ["موج بلند شد! رفتیم!"],
                        "nitro": ["تسونامی‌ای می‌آد!"],
                        "hit": ["بالام! بال مسابقه‌ایم!"],
                        "win": ["موج که میاد، همه رو با خودش می‌بره!"],
                        "lose": ["موج برمی‌گرده... بزرگ‌تر از قبل!"],
                        "taunt": ["شنا بلد نیستی، ماشین سواری هم که معلومه!", "آب که سر می‌کشه، ظرف می‌شوره — تو هم همین‌طور!"],
                },
        },
        "pejo_green": {
                "lakeb": "زمرد پیست",
                "sedasar": {"zomz": 350.0, "javse": 0.6, "nerkh": 11.0, "larz": 0.16},
                "harfha": {
                        "idle": ["زمردِ سبز پیست — استریک مشکی، شتاب وحشی!", "سبزم چون گازِ کوه دم می‌کشم!", "فنرم آهنیه، رگم هم!"],
                        "select": ["سبز شدی؟ یعنی رفاقتی!"],
                        "buy": ["سلیقه‌ات زرگری، انتخابت زمردی!"],
                        "poor": ["زمرد بی‌سکه نمی‌شه!"],
                        "upgrade": ["حالا وحشیِ وحشی‌ها!"],
                        "go": ["چراغ سبز — مال من!"],
                        "nitro": ["گازِ توگا!"],
                        "hit": ["لاستیک سبزمو!"],
                        "win": ["سبزی یعنی برد، دیگه!"],
                        "lose": ["دفعه بعد سبزتر و خشمگین‌تر!"],
                        "taunt": ["تو ماشین راه میری یا ماشین راه میره؟!", "گازِ من گیاهیه داداش، طبیعیه!"],
                },
        },
        "shahin_white": {
                "lakeb": "قهرمان سفید",
                "sedasar": {"zomz": 235.0, "javse": 0.55, "nerkh": 9.0, "larz": 0.12},
                "harfha": {
                        "idle": ["سفیدِ طلایی‌خط — قهرمانِ شب‌های تهران.", "نفسِ طلایی دارم؛ خط طلاییم هم همین‌طور.", "قهرمان ساکت می‌بره."],
                        "select": ["انتخابِ قهرمانانه."],
                        "buy": ["حالا تو هم تیم قهرمانی."],
                        "poor": ["طلایی‌خطی قیمت داره."],
                        "upgrade": ["حتی قهرمان‌ها هم ارتقا می‌خوان."],
                        "go": ["سکوتِ قبل از طوفان."],
                        "nitro": ["بالِ سفید باز شد!"],
                        "hit": ["خطِ طلاییم... مواظب باش!"],
                        "win": ["سکو از قبل جا گرفته بود."],
                        "lose": ["قهرمان می‌بازه؛ سلطنت نه."],
                        "taunt": ["سایه‌مو هم نمی‌رسی!", "قهرمان رو با جای دوم قاطی نکن داداش!"],
                },
        },
        "dena_red": {
                "lakeb": "کاپیتان سرخ",
                "sedasar": {"zomz": 260.0, "javse": 0.6, "nerkh": 9.5, "larz": 0.14},
                "harfha": {
                        "idle": ["کاپیتانِ سرخ مأموریت‌ها گزارش می‌ده: آماده‌ام!", "سرخِ مأموریت، سخت‌کوش و سریع!", "دستور بده؛ مأموریت انجام می‌شه!"],
                        "select": ["کاپیتان روی سینه‌اش دوخت... تو!"],
                        "buy": ["تیم دوتایی شد!"],
                        "poor": ["مأموریت‌ها جایزه می‌دن؛ جمع کن!"],
                        "upgrade": ["تجهیزاتِ کاپیتان کامل شد!"],
                        "go": ["مأموریت شروع شد — حرکت!"],
                        "nitro": ["بوسترِ کاپیتان فعال!"],
                        "hit": ["گزارش: آسیب جزئی؛ مأموریت ادامه دارد!"],
                        "win": ["مأموریت انجام شد، کاپیتان برمی‌گرده!"],
                        "lose": ["کاپیتان عقب نمی‌کشه؛ دوباره حمله!"],
                        "taunt": ["تو مأموریت دادی، ما تحویل گرفتیم!", "گردن کج نکن؛ خط پایان همینه!"],
                },
        },
        "nissan_blue": {
                "lakeb": "نیسانِ اکبر",
                "sedasar": {"zomz": 145.0, "javse": 0.9, "nerkh": 6.0, "larz": 0.08},
                "harfha": {
                        "idle": ["هوم. آبیِ اکبرم. لونگِ بابام به گردنه، آسفالت به چرخم.", "بار سنگین؟ خنده داره.", "اکبر گفت: ببرش خط پایان، برگردونش سالم."],
                        "select": ["سوار شو. اکبر خودش لاستیک‌هامو بسته."],
                        "buy": ["هوم. اکبر خوشحال می‌شه."],
                        "poor": ["اکبر می‌گه: سکه بیار."],
                        "upgrade": ["هوم. محکم‌تر از دیوارِ جنوب."],
                        "go": ["لونگو بستیم. رفتیم."],
                        "nitro": ["هوووم! نیسانِ پر!"],
                        "hit": ["گلگیرم... اکبر می‌فهمه. ولی می‌بخشه."],
                        "win": ["هوم. مثل همیشه."],
                        "lose": ["اکبر گفت: دوباره. حرف دیگه نزن."],
                        "taunt": ["سایه‌ی نیسان رو هم تیکه می‌ندازن، تو چی!", "واسه چراغ قرمز هم دیر می‌رسی داداش!"],
                },
        },
        "formula_red": {
                "lakeb": "فرمول آتش",
                "sedasar": {"zomz": 430.0, "javse": 0.85, "nerkh": 14.0, "larz": 0.22},
                "harfha": {
                        "idle": ["بال جلو! بال عقب! جون نصف!", "سرخِ توربوی پیستم — چرخام زمین رو گاز می‌کنن!", "نیم‌گرمِ موتور که شد، دیگه هیچی جلودارم نیست!"],
                        "select": ["ایول! بالاخره پیست واقعی!"],
                        "buy": ["به تیم آتش خوش اومدی!"],
                        "poor": ["توربو گرونه رفیق!"],
                        "upgrade": ["حالا سوخت‌گیریِ بلندترم!"],
                        "go": ["چراغا خاموش... آتش!"],
                        "nitro": ["بوووستِ توربویی!"],
                        "hit": ["ایرودینامیکم! آخ!"],
                        "win": ["سکوی اول، مال همیشه!"],
                        "lose": ["پیت‌استاپ می‌زنم و برمی‌گردم!"],
                        "taunt": ["چرخامو فرسودی، هنوز رد شدم!", "مکانیک بذار کنار، اون‌طوری هم نمی‌رسه!"],
                },
        },
        "formula_blue": {
                "lakeb": "فرمول موج",
                "sedasar": {"zomz": 470.0, "javse": 0.7, "nerkh": 15.0, "larz": 0.24},
                "harfha": {
                        "idle": ["آبیِ تازه‌کار ولی بی‌باک!", "موج‌ها می‌گن سریع‌ترینم!", "هر روز بهتر از دیروز — شعارم همینه!"],
                        "select": ["وای وای وای! بریم بریم بریم!"],
                        "buy": ["بهترین روز زندگیمه!"],
                        "poor": ["آخ! سکه‌هام هنوز کمه!"],
                        "upgrade": ["حالا از خودمم سریع‌ترم!"],
                        "go": ["سه، دو، یک... پرتاب!"],
                        "nitro": ["یِهِهِهِه! پرندم!"],
                        "hit": ["وای! بال نازکم!"],
                        "win": ["گفتم که می‌برم! گفتم!"],
                        "lose": ["دفعه بعد با نیتروی دوبرابر!"],
                        "taunt": ["هنوز داری گرم می‌شی؟ ما رفتیم برگشتیم!", "عینکمی که زدی کمک نمی‌کنه!"],
                },
        },
        "formula_black": {
                "lakeb": "فرمول شاهین",
                "sedasar": {"zomz": 205.0, "javse": 0.6, "nerkh": 8.5, "larz": 0.1},
                "harfha": {
                        "idle": ["مشکی-طلایی. شب که بشه، رکورد می‌شکنم.", "صدای موتورم رو که بشنوی، صبح رو می‌بینی.", "بالای سرت بال طلاییم رد می‌شه."],
                        "select": ["انتخابِ درست. همیشه."],
                        "buy": ["تاج سرت بذار."],
                        "poor": ["تاج قیمت داره."],
                        "upgrade": ["حالا حتی سایه‌ام سریع‌تره."],
                        "go": ["پرواز آغاز."],
                        "nitro": ["شبِ سیاه، خطِ طلایی!"],
                        "hit": ["بال طلاییم را گرفتند... بی‌رحم‌تر می‌شوم."],
                        "win": ["رکورد جا افتاد."],
                        "lose": ["شب هنوز جوان است."],
                        "taunt": ["عقب موندن شغل توئه، جلو رفتن شغل من!", "ساعتِ شبی را ببین؛ هنوز دور اولی!"],
                },
        },
        "akbar": {
                "lakeb": "اکبر سیبیلو",
                "sedasar": {"zomz": 165.0, "javse": 0.8, "nerkh": 8.0, "larz": 0.12},
                "harfha": {
                        "idle": ["سلام سلام! اکبرم؛ سیبیلوم، لونگم، نیسانم آبی!", "مأموریت امروز سخته، ولی ما از اون سخت‌تریم!", "تو این محل هیچ‌کس با اکبر رقابت نمی‌کنه، جز چراغ قرمز!", "گازِ نیسان که می‌ره پایین، حرفم بالا می‌ره!"],
                        "go": ["جا خالی کن! لونگو بستیم، رفتیم!"],
                        "nitro": ["حالا نیسان رو ببین چجوری می‌پره!"],
                        "hit": ["ای وای، لونگو خیس کردی!"],
                        "win": ["آفرین رفیق! شب شیرینه امشب!"],
                        "lose": ["ناز نکن! اکبر و نیسان پشتمونن!"],
                        "taunt": ["بیا ببین پدرت اومد تو جاده!", "سیبیلمو بوس بزن که رد شدم!"],
                },
        },
        "ustad": {
                "lakeb": "استاد فنر",
                "sedasar": {"zomz": 210.0, "javse": 0.5, "nerkh": 8.0, "larz": 0.12},
                "harfha": {
                        "idle": ["بیا بیا! ماشینت رو به من بسپار!", "آچار شماره‌ی چهارده کو؟!", "کارِ استاد که تمیزه دیگه!", "سیبیلَم رو بوس بزن، کارتم تمومه!"],
                        "upgrade": ["هیس... الان صدای موتور رو ببین!"],
                        "buy": ["انتخابِ خوبی بود جوانمرد!"],
                        "hit": ["دوباره تصادف؟ بیا ببینم..."],
                },
        },
}

## بانک کری کوچه‌بازاری — تیکه‌های شیرینِ بعد از خط پایان (بدون فحش؛ بازارپسند)
const TAANEHA := [
        "بیا برس! نه، الان که نمی‌رسه!",
        "آینه رو نگاه کن که کی رد شد!",
        "چراغ قرمز هم دنبالت می‌گرده!",
        "دنده رو وارونه زدی داداش!",
        "موتورم گرمه، دلت که سرد شد!",
        "پارک دبل مال من، خط پایانم همین‌طور!",
        "لاستیکم بهتره، راننده‌م هم!",
        "ساعت نهم شبی، تو هنوز تو دور برگشتی!",
        "این سرعت؟ ما با پای پیاده خنده‌دارتریم!",
        "من مسابقه دادم، تو داری قدم می‌زنی!",
        "بوق بزن شاید صدات اومد!",
        "هنوز داری گرم می‌شی؟ ما رفتیم برگشتیم!",
        "سایه‌مو هم نمی‌رسی!",
        "گاز کافیه، عامل کمه!",
]

const HALEHA := {
        "idle": "chill", "select": "happy", "buy": "happy", "poor": "grumpy",
        "upgrade": "happy", "go": "happy", "nitro": "happy", "hit": "grumpy",
        "win": "happy", "lose": "chill", "boost": "happy", "taunt": "happy",
}

static var _akharin_aram := {}
static var _tasadofi_sabet := RandomNumberGenerator.new()

var hobab: Control = null
var pakhsh_ava: AudioStreamPlayer = null
var ava_fa_al := false # صدای لاله‌زبان خاموش (بازخورد کاربر: «صدا زشته») — حباب متنی کافی است
var _tasadofi := RandomNumberGenerator.new()
var _nesh_mashin := 0

func _ready() -> void:
        _tasadofi.randomize()
        pakhsh_ava = AudioStreamPlayer.new()
        pakhsh_ava.volume_db = -2.0
        add_child(pakhsh_ava)

## خطِ تصادفی برای ماشین و موقعیت — اگر تیکه‌ی شخصی نداشت از بانک عمومیِ کری شلیک می‌شود
static func goftare_begozin(shenase_mashin: String, vaqeiat: String) -> String:
        if not SHAKHSIATHA.has(shenase_mashin):
                return ""
        var hoozeh: Array = SHAKHSIATHA[shenase_mashin]["harfha"].get(vaqeiat, [])
        if hoozeh.is_empty() and vaqeiat == "taunt":
                hoozeh = TAANEHA
        if hoozeh.is_empty():
                return ""
        var klid := shenase_mashin + ":" + vaqeiat
        var pishin: int = int(_akharin_aram.get(klid, -1))
        var i := _tasadofi_sabet.randi_range(0, hoozeh.size() - 1)
        if hoozeh.size() > 1 and i == pishin:
                i = (i + 1) % hoozeh.size()
        _akharin_aram[klid] = i
        return str(hoozeh[i])

## سکوت همیشگی نیست — ماشین‌ها هر از چندی خودشان حرف می‌زنند
func gap_aram(langar_sazi: Callable, shenase_sazi: Callable, intezar_kam := 7.0, intezar_bis := 13.0) -> void:
        var t := Timer.new()
        t.wait_time = _tasadofi.randf_range(intezar_kam, intezar_bis)
        t.one_shot = false
        t.timeout.connect(func():
                var shenaseha: Array = shenase_sazi.call()
                if shenaseha.is_empty():
                        return
                var shenase: String = shenaseha[_tasadofi.randi_range(0, shenaseha.size() - 1)]
                var langar: Control = langar_sazi.call(shenase)
                if langar != null and langar.is_visible_in_tree():
                        begu(langar, shenase, "idle")
                t.wait_time = _tasadofi.randf_range(intezar_kam, intezar_bis))
        add_child(t)
        t.start()

## حبابِ گفتار باز می‌شود + صدای لاله‌زبانِ همان ماشین پخش می‌شود
func begu(langar: Control, shenase_mashin: String, vaqeiat: String) -> void:
        if not SHAKHSIATHA.has(shenase_mashin):
                return
        var khat_harf := goftare_begozin(shenase_mashin, vaqeiat)
        if khat_harf.is_empty():
                return
        for i in Saman.MASHINHA.size():
                if str(Saman.MASHINHA[i]["shenase"]) == shenase_mashin:
                        _nesh_mashin = i
                        break
        _hobab_neshan(langar, khat_harf)
        _ava_sazi(khat_harf, shenase_mashin, str(HALEHA.get(vaqeiat, "chill")))
        Shakhsiat.larzesh_kon(langar)

func _hobab_neshan(langar: Control, text: String) -> void:
        if hobab != null:
                hobab.queue_free()
                hobab = null
        var b := Hobab.new()
        b.saheb = self
        b.matn_bezan(text)
        var khatt_e: Resource = load("res://assets/fonts/Lalezar-Regular.ttf")
        if khatt_e is FontFile:
                b.add_theme_font_override("font", khatt_e)
        var top := langar.global_position
        var w := maxf(190.0, minf(400.0, text.length() * 13.0 + 70.0))
        b.size = Vector2(w, 0)
        var px := top.x + langar.size.x * 0.5 - w * 0.5
        px = clampf(px, 12.0, 1280.0 - w - 12.0)
        var py := top.y - 86.0
        if py < 8.0:
                py = top.y + langar.size.y + 10.0
        b.position = Vector2(px, py)
        b.z_index = 60
        var greh_padar := langar.get_parent()
        if greh_padar == null:
                greh_padar = self
        greh_padar.add_child(b)
        hobab = b

## صدای لاله‌زبان — یک جمله‌ی بی‌کلامِ آهنگین که شخصیتِ ماشین را می‌سازد
func _ava_sazi(text: String, shenase_mashin: String, halat: String) -> void:
        if not ava_fa_al:
                return # پیش‌فرض سکوت — ریتم طنز از متن می‌آید نه از بوق سینوسی
        var v: Dictionary = SHAKHSIATHA[shenase_mashin]["sedasar"] if SHAKHSIATHA.has(shenase_mashin) else {"zomz": 300.0, "javse": 0.5, "nerkh": 10.0, "larz": 0.15}
        var pitch := float(v["zomz"])
        var tone := float(v["javse"])
        var rate := float(v["nerkh"])
        var jit := float(v["larz"])
        var moddat_seela := 1.0 / rate
        var moddat := clampf(0.25 + text.length() * 0.045, 0.45, 2.4)
        var seelaha := int(ceil(moddat / moddat_seela))
        var nerkh_namune := 22050
        var tedad := int(moddat * nerkh_namune)
        var dadeh := PackedByteArray()
        dadeh.resize(tedad * 2)
        var sahne := 0.0
        for k in seelaha:
                var zomz_seela := pitch * (1.0 + _tasadofi.randf_range(-jit, jit))
                if halat == "happy":
                        zomz_seela *= 1.0 + 0.06 * float(k) / float(seelaha) # آهنگین رو به بالا
                elif halat == "grumpy":
                        zomz_seela *= 1.0 - 0.05 * float(k) / float(seelaha)
                var ghaam := 2.0 * PI * zomz_seela / float(nerkh_namune)
                var s0 := int(float(k) * moddat_seela * nerkh_namune)
                var s1: int = min(tedad, int(float(k + 1) * moddat_seela * nerkh_namune) - int(nerkh_namune * 0.02))
                for i in range(s0, s1):
                        var tt := float(i - s0) / float(nerkh_namune)
                        var dar_seela := float(i - s0) / float(moddat_seela * nerkh_namune)
                        var posh := pow(maxf(0.0, sin(PI * clampf(dar_seela, 0.0, 1.0))), 0.65)
                        if tt < 0.01 or tt > moddat_seela - 0.03:
                                posh = 0.0
                        var s := sin(sahne)
                        var moraba := signf(s)
                        var nam_e := 1.0 + 0.02 * sin(2.0 * PI * 6.0 * tt)
                        var damane := posh * 0.34 * nam_e
                        var meghdar := (1.0 - tone) * s + tone * moraba
                        var daghigh := int(clampf(meghdar * damane, -1.0, 1.0) * 32767.0)
                        dadeh.encode_s16(i * 2, daghigh)
                        sahne += ghaam
        var jaryan := AudioStreamWAV.new()
        jaryan.format = AudioStreamWAV.FORMAT_16_BITS
        jaryan.mix_rate = nerkh_namune
        jaryan.stereo = false
        jaryan.dadeh = dadeh
        pakhsh_ava.stream = jaryan
        pakhsh_ava.pitch_scale = 1.0
        pakhsh_ava.play()

## نفس‌کشیدن دائمی ماشین‌ها — حس زنده بودن مثل انیمیشن‌های معروف
static func nafas(greh_e: Control, damane := 3.5, moddat := 1.3) -> void:
        var paye := greh_e.position.y
        var t := greh_e.create_tween().set_loops()
        t.tween_property(greh_e, "position:y", paye - damane, moddat).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
        t.tween_property(greh_e, "position:y", paye + damane * 0.4, moddat).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

## جست‌وخیزِ لحظه‌ی حرف زدن — با مقیاس و چرخش تا با تنفسِ دائمی تداخل نکند
static func larzesh_kon(greh_e: Control) -> void:
        if greh_e == null or not is_instance_valid(greh_e):
                return
        var t := greh_e.create_tween()
        t.tween_property(greh_e, "rotation_degrees", 2.2, 0.09).set_trans(Tween.TRANS_SINE)
        t.parallel().tween_property(greh_e, "scale", greh_e.scale * Vector2(1.03, 1.07), 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
        t.tween_property(greh_e, "rotation_degrees", -1.6, 0.12).set_trans(Tween.TRANS_SINE)
        t.tween_property(greh_e, "rotation_degrees", 0.0, 0.1)
        t.parallel().tween_property(greh_e, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

## حبابِ گفتار — پنل کرم با دنباله، متن با افکت تایپ
class Hobab extends Control:
        var yazanak: Label
        var saheb: Shakhsiat
        var _t := 0.0
        var _total := 0.0
        var _hold := 0.0

        func matn_bezan(text: String) -> void:
                var ghalati := StyleBoxFlat.new()
                ghalati.bg_color = Color(0.99, 0.965, 0.88, 0.97)
                ghalati.set_corner_radius_all(16)
                ghalati.border_color = Color(0.29, 0.216, 0.157)
                ghalati.border_width_left = 3
                ghalati.border_width_right = 3
                ghalati.border_width_top = 3
                ghalati.border_width_bottom = 3
                ghalati.shadow_color = Color(0, 0, 0, 0.3)
                ghalati.shadow_size = 6
                var panel := PanelContainer.new()
                panel.add_theme_stylebox_override("panel", ghalati)
                panel.set_anchors_preset(Control.PRESET_FULL_RECT)
                yazanak = Label.new()
                yazanak.text = text
                yazanak.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
                yazanak.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
                yazanak.add_theme_font_size_override("font_size", 24)
                yazanak.add_theme_color_override("font_color", Color(0.22, 0.14, 0.07))
                var m := MarginContainer.new()
                m.add_theme_constant_override("margin_left", 16)
                m.add_theme_constant_override("margin_right", 16)
                m.add_theme_constant_override("margin_top", 10)
                m.add_theme_constant_override("margin_bottom", 14)
                m.add_child(yazanak)
                panel.add_child(m)
                add_child(panel)
                yazanak.visible_characters = 0
                _total = float(text.length())
                _hold = _total * 0.055 + 1.3

        func _ready() -> void:
                mouse_filter = Control.MOUSE_FILTER_IGNORE
                scale = Vector2(0.2, 0.2)
                var t := create_tween()
                t.tween_property(self, "scale", Vector2(1, 1), 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

        func _process(delta: float) -> void:
                _t += delta
                if yazanak != null and _t < _total * 0.055:
                        yazanak.visible_characters = int(_t / 0.055) + 1
                if _t > _hold:
                        modulate.a -= delta * 2.5
                        position.y -= delta * 14.0
                        if modulate.a <= 0.0:
                                queue_free()
