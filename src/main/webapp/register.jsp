<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register | Palestine Relief</title>

    <%-- Google Fonts: Lora (headings) + DM Sans (body text) --%>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,400;0,600;1,400&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">

    <style>
        /* ── CSS RESET ──────────────────────────────────────────── */
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        /* ── THEME VARIABLES ────────────────────────────────────
           Two themes: dark and light.
           Switching data-theme on <html> swaps all colors.
           Theme saved to localStorage key 'donorTheme'. */
        [data-theme="dark"] {
            --bg:      #0b0e14;
            --surface: #13171f;
            --surface2:#1a1f2b;
            --border:  rgba(255,255,255,0.07);
            --text:    #e6e8f0;
            --text2:   #9ba3b8;
            --muted:   #5a6278;
            --shadow:  rgba(0,0,0,0.5);
        }
        [data-theme="light"] {
            --bg:      #f2f4f8;
            --surface: #ffffff;
            --surface2:#f7f8fc;
            --border:  rgba(0,0,0,0.08);
            --text:    #181c2a;
            --text2:   #4a5068;
            --muted:   #9ba3b8;
            --shadow:  rgba(0,0,0,0.08);
        }

        /* ── GLOBAL COLOR TOKENS ─────────────────────────────── */
        :root {
            --green:     #1db954;
            --green-dim: rgba(29,185,84,0.12);
            --red:       #e63946;
            --gold:      #f4a261;
        }

        /* ── BODY ───────────────────────────────────────────────
           Centered vertically and horizontally.
           ::before = subtle radial gradient glow (green + gold)
           ::after  = Palestine flag watermark (opacity 3%) */
        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--bg); color: var(--text);
            min-height: 100vh; display: flex;
            align-items: center; justify-content: center;
            transition: background .25s, color .25s;
            position: relative; overflow-x: hidden;
            padding: 40px 20px; /* padding allows card to scroll on small screens */
        }
        body::before {
            content: '';
            position: fixed; inset: 0;
            background-image:
                radial-gradient(circle at 20% 30%, rgba(29,185,84,0.06) 0%, transparent 50%),
                radial-gradient(circle at 80% 70%, rgba(244,162,97,0.04) 0%, transparent 50%);
            pointer-events: none;
        }
        body::after {
            content: '🇵🇸';
            position: fixed; bottom: -40px; right: -20px;
            font-size: 220px; opacity: .03; pointer-events: none;
            transform: rotate(-12deg);
        }

        /* ── THEME TOGGLE BUTTON ────────────────────────────────
           Fixed top-right. Shows moon/sun emoji.
           Calls toggleTheme() to swap dark/light. */
        .theme-btn {
            position: fixed; top: 20px; right: 20px;
            width: 36px; height: 36px; border-radius: 9px;
            background: var(--surface); border: 1px solid var(--border);
            cursor: pointer; font-size: 16px;
            display: flex; align-items: center; justify-content: center;
            transition: border-color .2s, background .25s; z-index: 10;
        }
        .theme-btn:hover { border-color: var(--green); }

        /* ── REGISTRATION CARD ──────────────────────────────────
           Centered white/dark card containing the registration form.
           Max-width 420px. Fades in with fadeUp animation. */
        .card {
            background: var(--surface); border: 1px solid var(--border);
            border-radius: 16px; padding: 40px 36px;
            width: 100%; max-width: 420px;
            box-shadow: 0 8px 40px var(--shadow);
            animation: fadeUp .45s ease both;
            transition: background .25s, border-color .25s;
        }

        /* ── BRAND ──────────────────────────────────────────────
           "Palestine Relief" brand name centered at top of card */
        .brand { display: flex; align-items: center; gap: 10px; justify-content: center; margin-bottom: 28px; }
        .brand-icon { width: 38px; height: 38px; border-radius: 10px; background: var(--green-dim); border: 1px solid rgba(29,185,84,0.25); display: flex; align-items: center; justify-content: center; font-size: 19px; }
        .brand-name { font-family: 'Lora', serif; font-size: 19px; font-weight: 600; }
        .brand-name span { color: var(--green); }

        /* ── CARD TITLE AND SUBTITLE ────────────────────────────
           "Create Account" heading + "Join thousands helping Palestine" sub */
        .card-title { font-family: 'Lora', serif; font-size: 22px; font-weight: 600; text-align: center; margin-bottom: 4px; }
        .card-sub   { font-size: 13px; color: var(--muted); text-align: center; margin-bottom: 28px; }

        /* ── SECTION DIVIDER ────────────────────────────────────
           Horizontal line with label used to separate form sections.
           Used between "Account Info" and "Account Recovery" sections. */
        .section-divider {
            display: flex; align-items: center; gap: 10px;
            margin: 18px 0 14px; color: var(--muted); font-size: 11px;
            text-transform: uppercase; letter-spacing: .7px; font-weight: 600;
        }
        .section-divider::before, .section-divider::after { content: ''; flex: 1; height: 1px; background: var(--border); }

        /* ── FORM FIELDS ────────────────────────────────────────
           Standard label + input/select pairs with green focus ring.
           .valid = green border (passes validation)
           .invalid = red border (fails validation) */
        .field { display: flex; flex-direction: column; gap: 6px; margin-bottom: 14px; }
        .field label { font-size: 11.5px; font-weight: 600; text-transform: uppercase; letter-spacing: .7px; color: var(--muted); }
        .field input, .field select {
            background: var(--surface2); border: 1px solid var(--border);
            color: var(--text); padding: 11px 14px;
            border-radius: 8px; font-size: 14px; font-family: inherit;
            outline: none; width: 100%;
            transition: border-color .18s, box-shadow .18s, background .25s;
            appearance: none; /* removes default browser select styling */
        }
        .field input::placeholder { color: var(--muted); }
        .field input:focus, .field select:focus { border-color: var(--green); box-shadow: 0 0 0 3px rgba(29,185,84,0.1); }
        .field input.valid   { border-color: var(--green); }
        .field input.invalid { border-color: var(--red); box-shadow: 0 0 0 3px rgba(230,57,70,0.08); }

        /* ── CUSTOM SELECT ARROW ────────────────────────────────
           Custom dropdown arrow replaces browser default.
           Wraps the <select> element. */
        .select-wrap { position: relative; }
        .select-wrap::after { content: '▾'; position: absolute; right: 14px; top: 50%; transform: translateY(-50%); color: var(--muted); pointer-events: none; font-size: 13px; }
        .select-wrap select { padding-right: 36px; cursor: pointer; }
        .select-wrap select option { background: var(--surface2); color: var(--text); }

        /* ── PASSWORD SHOW/HIDE TOGGLE ──────────────────────────
           Eye button positioned inside password fields.
           Calling togglePw() switches type="password"/"text". */
        .pw-wrap { position: relative; }
        .pw-wrap input { padding-right: 42px; }
        .pw-eye { position: absolute; right: 12px; top: 50%; transform: translateY(-50%); cursor: pointer; font-size: 15px; opacity: .5; transition: opacity .18s; background: none; border: none; padding: 0; }
        .pw-eye:hover { opacity: 1; }

        /* ── PASSWORD REQUIREMENTS PANEL ────────────────────────
           Hidden by default. Shown when user starts typing password.
           Each of 5 requirements turns green with ✓ when met.
           Checked live by checkPassword() JS function. */
        .pw-reqs { background: var(--surface2); border: 1px solid var(--border); border-radius: 8px; padding: 12px 14px; margin-top: 6px; display: none; transition: background .25s, border-color .25s; }
        .pw-reqs.visible { display: block; }
        .pw-reqs-title { font-size: 11px; text-transform: uppercase; letter-spacing: .7px; color: var(--muted); margin-bottom: 8px; font-weight: 600; }
        .req { display: flex; align-items: center; gap: 8px; font-size: 12.5px; color: var(--muted); padding: 3px 0; transition: color .2s; }
        .req-icon { font-size: 13px; width: 16px; text-align: center; flex-shrink: 0; }
        .req.met { color: var(--green); }

        /* ── PASSWORD MATCH MESSAGE ─────────────────────────────
           Shown below confirm password field.
           Green "✓ match" or red "✗ no match".
           Checked live by checkConfirm() JS function. */
        .match-msg { font-size: 12px; margin-top: 5px; display: none; }
        .match-msg.ok  { color: var(--green); display: block; }
        .match-msg.bad { color: var(--red);   display: block; }

        /* ── SUBMIT BUTTON ──────────────────────────────────────
           Disabled until ALL conditions are met:
             - username not empty
             - all 5 password requirements passed (pwAllMet)
             - passwords match (confirmOk)
             - security question selected
             - security answer not empty
           Enabled by updateSubmit() which runs on every field change. */
        .btn-submit { width: 100%; background: var(--green); color: #051a0d; border: none; padding: 12px; border-radius: 8px; font-size: 14.5px; font-weight: 700; cursor: pointer; font-family: inherit; letter-spacing: .2px; transition: opacity .18s, transform .1s; margin-top: 6px; }
        .btn-submit:hover    { opacity: .88; transform: translateY(-1px); }
        .btn-submit:active   { transform: translateY(0); }
        .btn-submit:disabled { opacity: .4; cursor: not-allowed; transform: none; }

        /* ── ERROR BOX ──────────────────────────────────────────
           Red box shown when RegisterServlet redirects back with
           an ?error= parameter (e.g. taken, mismatch, weak).
           Shakes on appear to draw attention. */
        .error-box { display: flex; align-items: center; gap: 8px; background: rgba(230,57,70,0.08); border: 1px solid rgba(230,57,70,0.25); border-radius: 8px; padding: 10px 14px; margin-bottom: 16px; animation: shake .35s ease; }
        .error-box span { font-size: 13px; color: var(--red); }

        /* ── FOOTER ─────────────────────────────────────────────
           "Already have an account? Sign in" → login.jsp */
        .divider { display: flex; align-items: center; gap: 10px; margin: 20px 0; color: var(--muted); font-size: 12px; }
        .divider::before, .divider::after { content: ''; flex: 1; height: 1px; background: var(--border); }
        .card-footer { text-align: center; font-size: 13px; color: var(--muted); }
        .card-footer a { color: var(--green); text-decoration: none; font-weight: 500; }
        .card-footer a:hover { text-decoration: underline; }

        /* ── ANIMATIONS ─────────────────────────────────────────
           fadeUp: card appears with upward slide on load
           shake: error box shakes when it appears */
        @keyframes fadeUp { from{opacity:0;transform:translateY(16px);}to{opacity:1;transform:none;} }
        @keyframes shake  { 0%,100%{transform:translateX(0);}25%{transform:translateX(-6px);}75%{transform:translateX(6px);} }
    </style>
</head>
<body>

<%-- Theme toggle: fixed top-right button --%>
<button class="theme-btn" onclick="toggleTheme()" id="themeBtn">🌙</button>

<div class="card">

    <%-- Brand name at top of card --%>
    <div class="brand">
        <div class="brand-name">Palestine <span>Relief</span></div>
    </div>

    <div class="card-title">Create Account</div>
    <div class="card-sub">Join thousands helping Palestine</div>

    <%-- ── ERROR BOX ────────────────────────────────────────────
         Shown when RegisterServlet redirects back with ?error= parameter.
         Each error code maps to a human-readable message:
           1        = general failure
           mismatch = passwords don't match (server-side check)
           weak     = password too simple (server-side check)
           taken    = username already exists in DB
           database = SQL/connection error --%>
    <%
        String error = request.getParameter("error");
        String errorMsg = null;
        if      ("1".equals(error))             errorMsg = "Registration failed. Please try again.";
        else if ("mismatch".equals(error))      errorMsg = "Passwords do not match.";
        else if ("weak".equals(error))          errorMsg = "Password does not meet the requirements.";
        else if ("taken".equals(error))         errorMsg = "That username is already taken.";
        else if ("database".equals(error))      errorMsg = "A database error occurred. Please try again.";
        if (errorMsg != null) {
    %>
    <div class="error-box"><span>⚠️ <%= errorMsg %></span></div>
    <% } %>

    <%-- ── REGISTRATION FORM ──────────────────────────────────────
         Submits POST to RegisterServlet (/register).
         RegisterServlet:
           1. Checks username is not already taken
           2. Hashes password with BCrypt.hashpw()
           3. Hashes security answer with BCrypt.hashpw() (lowercased)
           4. Inserts new user into users table with role = 'DONOR'
           5. Redirects to login.jsp?msg=registered on success --%>
    <form action="register" method="post" id="regForm">

        <%-- ── SECTION 1: ACCOUNT INFO ─────────────────────────── --%>

        <%-- Username — must be unique in DB (checked by RegisterServlet) --%>
        <div class="field">
            <label>Username</label>
            <input type="text" name="username" id="usernameInput"
                   placeholder="Choose a username" required autocomplete="username">
        </div>

        <%-- Password with:
             - Eye toggle (show/hide)
             - Live requirements panel (shown on first keystroke)
             - checkPassword() validates each of 5 requirements in real-time --%>
        <div class="field">
            <label>Password</label>
            <div class="pw-wrap">
                <input type="password" name="password" id="pwInput"
                       placeholder="Create a password" required autocomplete="new-password"
                       oninput="checkPassword()">
                <button type="button" class="pw-eye" onclick="togglePw('pwInput','eye1')" id="eye1">👁️</button>
            </div>
            <%-- Requirements panel — hidden until user starts typing --%>
            <div class="pw-reqs" id="pwReqs">
                <div class="pw-reqs-title">Password must have:</div>
                <div class="req unmet" id="req-len">  <span class="req-icon">○</span> At least 8 characters</div>
                <div class="req unmet" id="req-upper"><span class="req-icon">○</span> One uppercase letter (A–Z)</div>
                <div class="req unmet" id="req-lower"><span class="req-icon">○</span> One lowercase letter (a–z)</div>
                <div class="req unmet" id="req-num">  <span class="req-icon">○</span> One number (0–9)</div>
                <div class="req unmet" id="req-sym">  <span class="req-icon">○</span> One special character (!@#$…)</div>
            </div>
        </div>

        <%-- Confirm password with:
             - Eye toggle
             - Live match indicator (checkConfirm() on every keystroke) --%>
        <div class="field">
            <label>Confirm Password</label>
            <div class="pw-wrap">
                <input type="password" name="confirmPassword" id="confirmInput"
                       placeholder="Repeat your password" required autocomplete="new-password"
                       oninput="checkConfirm()">
                <button type="button" class="pw-eye" onclick="togglePw('confirmInput','eye2')" id="eye2">👁️</button>
            </div>
            <%-- Shows green "✓ match" or red "✗ no match" --%>
            <div class="match-msg" id="matchMsg"></div>
        </div>

        <%-- ── SECTION 2: ACCOUNT RECOVERY ──────────────────────
             Security question and answer used in forgot password flow.
             Answer is BCrypt hashed before storing — case-insensitive. --%>
        <div class="section-divider">Account Recovery</div>

        <%-- Security question dropdown — 5 preset options --%>
        <div class="field">
            <label>Security Question</label>
            <div class="select-wrap">
                <select name="securityQuestion" id="secQuestion" required onchange="updateSubmit()">
                    <option value="" disabled selected>Choose a question...</option>
                    <option value="pet">What was the name of your first pet?</option>
                    <option value="city">What city were you born in?</option>
                    <option value="mother">What is your mother's maiden name?</option>
                    <option value="school">What was the name of your primary school?</option>
                    <option value="friend">What is the name of your childhood best friend?</option>
                </select>
            </div>
        </div>

        <%-- Security answer — lowercased and BCrypt hashed by RegisterServlet --%>
        <div class="field">
            <label>Your Answer</label>
            <input type="text" name="securityAnswer" id="secAnswer"
                   placeholder="Answer (case-insensitive)" required autocomplete="off"
                   oninput="updateSubmit()">
        </div>

        <%-- Submit button: disabled until all 5 conditions are met via updateSubmit() --%>
        <button type="submit" class="btn-submit" id="submitBtn" disabled>Create Account</button>
    </form>

    <div class="divider">or</div>
    <%-- Link back to login for existing users --%>
    <div class="card-footer">Already have an account? <a href="login.jsp">Sign in</a></div>

</div>

<script>
    var html = document.documentElement;

    /* ── THEME ──────────────────────────────────────────────────
       On load: read saved theme from localStorage (default: dark).
       Shares 'donorTheme' key with all other pages so theme stays
       consistent across index, login, register, dashboard, etc. */
    (function() {
        var saved = localStorage.getItem('donorTheme') || 'dark';
        applyTheme(saved);
    })();

    function applyTheme(theme) {
        html.setAttribute('data-theme', theme);
        document.getElementById('themeBtn').textContent = theme === 'dark' ? '☀️' : '🌙';
        localStorage.setItem('donorTheme', theme);
    }
    function toggleTheme() {
        applyTheme(html.getAttribute('data-theme') === 'dark' ? 'light' : 'dark');
    }

    /* ── PASSWORD SHOW/HIDE ─────────────────────────────────────
       Each password field has its own eye button and input id.
       togglePw(inputId, btnId) switches type and emoji for that field. */
    function togglePw(inputId, btnId) {
        var input = document.getElementById(inputId);
        var btn   = document.getElementById(btnId);
        var hide  = input.type === 'password';
        input.type      = hide ? 'text' : 'password';
        btn.textContent = hide ? '🙈' : '👁️';
    }

    /* ── PASSWORD REQUIREMENTS CHECKER ─────────────────────────
       5 rules checked live as user types in the password field.
       Each rule has a corresponding div that turns green with ✓ when met.
       Also updates the password input border (valid/invalid class).
       Calls updateSubmit() after each check. */
    var rules = {
        'req-len':   function(v){ return v.length >= 8; },          // Min 8 chars
        'req-upper': function(v){ return /[A-Z]/.test(v); },        // One uppercase
        'req-lower': function(v){ return /[a-z]/.test(v); },        // One lowercase
        'req-num':   function(v){ return /\d/.test(v); },           // One number
        'req-sym':   function(v){ return /[^a-zA-Z0-9]/.test(v); }, // One special char
    };

    var pwAllMet  = false; // true when all 5 password rules pass
    var confirmOk = false; // true when both passwords match

    function checkPassword() {
        var val  = document.getElementById('pwInput').value;
        var reqs = document.getElementById('pwReqs');

        // Show requirements panel only when user starts typing
        reqs.classList.toggle('visible', val.length > 0);

        var allMet = true;
        for (var id in rules) {
            var met = rules[id](val);
            var el  = document.getElementById(id);
            // Toggle green "met" or grey "unmet" class
            el.className = 'req ' + (met ? 'met' : 'unmet');
            // Swap circle to checkmark when requirement is met
            el.querySelector('.req-icon').textContent = met ? '✓' : '○';
            if (!met) allMet = false;
        }
        pwAllMet = allMet;

        // Update border color of password input
        document.getElementById('pwInput').className =
            val.length === 0 ? '' : (allMet ? 'valid' : 'invalid');

        // Re-check confirm field if it already has a value
        if (document.getElementById('confirmInput').value.length > 0) checkConfirm();
        updateSubmit();
    }

    /* ── CONFIRM PASSWORD MATCH CHECKER ────────────────────────
       Compares password vs confirm password on every keystroke.
       Shows green match or red no-match message below confirm field.
       Calls updateSubmit() to enable/disable submit button. */
    function checkConfirm() {
        var pw  = document.getElementById('pwInput').value;
        var cfm = document.getElementById('confirmInput').value;
        var msg = document.getElementById('matchMsg');
        var inp = document.getElementById('confirmInput');

        if (cfm.length === 0) {
            // Empty — no message, no border color
            msg.className = 'match-msg'; inp.className = ''; confirmOk = false;
        } else if (pw === cfm) {
            // Match — green message and green border
            msg.className = 'match-msg ok'; msg.textContent = '✓ Passwords match';
            inp.className = 'valid'; confirmOk = true;
        } else {
            // No match — red message and red border
            msg.className = 'match-msg bad'; msg.textContent = '✗ Passwords do not match';
            inp.className = 'invalid'; confirmOk = false;
        }
        updateSubmit();
    }

    /* ── SUBMIT BUTTON STATE ────────────────────────────────────
       Submit button is only enabled when ALL 5 conditions pass:
         1. username is not empty
         2. all 5 password requirements met (pwAllMet)
         3. both passwords match (confirmOk)
         4. a security question is selected (not default empty option)
         5. security answer is not empty
       This prevents form submission with invalid or incomplete data. */
    function updateSubmit() {
        var username = document.getElementById('usernameInput').value.trim();
        var secQ     = document.getElementById('secQuestion').value;
        var secA     = document.getElementById('secAnswer').value.trim();
        document.getElementById('submitBtn').disabled =
            !(pwAllMet && confirmOk && username.length > 0 && secQ !== '' && secA.length > 0);
    }

    // Also listen to username input so submit button updates when username is typed
    document.getElementById('usernameInput').addEventListener('input', updateSubmit);
</script>
</body>
</html>