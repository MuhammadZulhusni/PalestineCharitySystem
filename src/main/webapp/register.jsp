<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register | Palestine Relief</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,400;0,600;1,400&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

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
        :root {
            --green:     #1db954;
            --green-dim: rgba(29,185,84,0.12);
            --red:       #e63946;
            --gold:      #f4a261;
        }

        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--bg); color: var(--text);
            min-height: 100vh; display: flex;
            align-items: center; justify-content: center;
            transition: background .25s, color .25s;
            position: relative; overflow-x: hidden;
            padding: 40px 20px;
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

        .theme-btn {
            position: fixed; top: 20px; right: 20px;
            width: 36px; height: 36px; border-radius: 9px;
            background: var(--surface); border: 1px solid var(--border);
            cursor: pointer; font-size: 16px;
            display: flex; align-items: center; justify-content: center;
            transition: border-color .2s, background .25s; z-index: 10;
        }
        .theme-btn:hover { border-color: var(--green); }

        .card {
            background: var(--surface); border: 1px solid var(--border);
            border-radius: 16px; padding: 40px 36px;
            width: 100%; max-width: 420px;
            box-shadow: 0 8px 40px var(--shadow);
            animation: fadeUp .45s ease both;
            transition: background .25s, border-color .25s;
        }

        .brand {
            display: flex; align-items: center; gap: 10px;
            justify-content: center; margin-bottom: 28px;
        }
        .brand-icon {
            width: 38px; height: 38px; border-radius: 10px;
            background: var(--green-dim); border: 1px solid rgba(29,185,84,0.25);
            display: flex; align-items: center; justify-content: center; font-size: 19px;
        }
        .brand-name { font-family: 'Lora', serif; font-size: 19px; font-weight: 600; }
        .brand-name span { color: var(--green); }

        .card-title { font-family: 'Lora', serif; font-size: 22px; font-weight: 600; text-align: center; margin-bottom: 4px; }
        .card-sub { font-size: 13px; color: var(--muted); text-align: center; margin-bottom: 28px; }

        .section-divider {
            display: flex; align-items: center; gap: 10px;
            margin: 18px 0 14px; color: var(--muted); font-size: 11px;
            text-transform: uppercase; letter-spacing: .7px; font-weight: 600;
        }
        .section-divider::before, .section-divider::after {
            content: ''; flex: 1; height: 1px; background: var(--border);
        }

        .field { display: flex; flex-direction: column; gap: 6px; margin-bottom: 14px; }
        .field label { font-size: 11.5px; font-weight: 600; text-transform: uppercase; letter-spacing: .7px; color: var(--muted); }
        .field input, .field select {
            background: var(--surface2); border: 1px solid var(--border);
            color: var(--text); padding: 11px 14px;
            border-radius: 8px; font-size: 14px; font-family: inherit;
            outline: none; width: 100%;
            transition: border-color .18s, box-shadow .18s, background .25s;
            appearance: none;
        }
        .field input::placeholder { color: var(--muted); }
        .field input:focus, .field select:focus { border-color: var(--green); box-shadow: 0 0 0 3px rgba(29,185,84,0.1); }
        .field input.valid   { border-color: var(--green); }
        .field input.invalid { border-color: var(--red); box-shadow: 0 0 0 3px rgba(230,57,70,0.08); }

        /* select arrow */
        .select-wrap { position: relative; }
        .select-wrap::after {
            content: '▾'; position: absolute; right: 14px; top: 50%;
            transform: translateY(-50%); color: var(--muted);
            pointer-events: none; font-size: 13px;
        }
        .select-wrap select { padding-right: 36px; cursor: pointer; }
        .select-wrap select option { background: var(--surface2); color: var(--text); }

        .pw-wrap { position: relative; }
        .pw-wrap input { padding-right: 42px; }
        .pw-eye {
            position: absolute; right: 12px; top: 50%;
            transform: translateY(-50%);
            cursor: pointer; font-size: 15px; opacity: .5;
            transition: opacity .18s; background: none; border: none; padding: 0;
        }
        .pw-eye:hover { opacity: 1; }

        .pw-reqs {
            background: var(--surface2); border: 1px solid var(--border);
            border-radius: 8px; padding: 12px 14px; margin-top: 6px;
            display: none; transition: background .25s, border-color .25s;
        }
        .pw-reqs.visible { display: block; }
        .pw-reqs-title { font-size: 11px; text-transform: uppercase; letter-spacing: .7px; color: var(--muted); margin-bottom: 8px; font-weight: 600; }
        .req { display: flex; align-items: center; gap: 8px; font-size: 12.5px; color: var(--muted); padding: 3px 0; transition: color .2s; }
        .req-icon { font-size: 13px; width: 16px; text-align: center; flex-shrink: 0; }
        .req.met { color: var(--green); }
        .req.unmet { color: var(--muted); }

        .match-msg { font-size: 12px; margin-top: 5px; display: none; }
        .match-msg.ok  { color: var(--green); display: block; }
        .match-msg.bad { color: var(--red);   display: block; }

        .btn-submit {
            width: 100%; background: var(--green); color: #051a0d;
            border: none; padding: 12px; border-radius: 8px;
            font-size: 14.5px; font-weight: 700; cursor: pointer;
            font-family: inherit; letter-spacing: .2px;
            transition: opacity .18s, transform .1s; margin-top: 6px;
        }
        .btn-submit:hover { opacity: .88; transform: translateY(-1px); }
        .btn-submit:active { transform: translateY(0); }
        .btn-submit:disabled { opacity: .4; cursor: not-allowed; transform: none; }

        .error-box {
            display: flex; align-items: center; gap: 8px;
            background: rgba(230,57,70,0.08); border: 1px solid rgba(230,57,70,0.25);
            border-radius: 8px; padding: 10px 14px; margin-bottom: 16px;
            animation: shake .35s ease;
        }
        .error-box span { font-size: 13px; color: var(--red); }

        .divider { display: flex; align-items: center; gap: 10px; margin: 20px 0; color: var(--muted); font-size: 12px; }
        .divider::before, .divider::after { content: ''; flex: 1; height: 1px; background: var(--border); }

        .card-footer { text-align: center; font-size: 13px; color: var(--muted); }
        .card-footer a { color: var(--green); text-decoration: none; font-weight: 500; }
        .card-footer a:hover { text-decoration: underline; }

        @keyframes fadeUp { from{opacity:0;transform:translateY(16px);}to{opacity:1;transform:none;} }
        @keyframes shake { 0%,100%{transform:translateX(0);}25%{transform:translateX(-6px);}75%{transform:translateX(6px);} }
    </style>
</head>
<body>

<button class="theme-btn" onclick="toggleTheme()" id="themeBtn">🌙</button>

<div class="card">

    <div class="brand">
        <div class="brand-name">Palestine <span>Relief</span></div>
    </div>

    <div class="card-title">Create Account</div>
    <div class="card-sub">Join thousands helping Palestine</div>

    <%
        String error = request.getParameter("error");
        String errorMsg = null;
        if ("1".equals(error))             errorMsg = "Registration failed. Please try again.";
        else if ("mismatch".equals(error)) errorMsg = "Passwords do not match.";
        else if ("weak".equals(error))     errorMsg = "Password does not meet the requirements.";
        else if ("taken".equals(error))    errorMsg = "That username is already taken.";
        else if ("database".equals(error)) errorMsg = "A database error occurred. Please try again.";
        if (errorMsg != null) {
    %>
    <div class="error-box"><span>⚠️ <%= errorMsg %></span></div>
    <% } %>

    <form action="register" method="post" id="regForm">

        <!-- ── ACCOUNT INFO ── -->
        <div class="field">
            <label>Username</label>
            <input type="text" name="username" id="usernameInput"
                   placeholder="Choose a username" required autocomplete="username">
        </div>

        <div class="field">
            <label>Password</label>
            <div class="pw-wrap">
                <input type="password" name="password" id="pwInput"
                       placeholder="Create a password" required autocomplete="new-password"
                       oninput="checkPassword()">
                <button type="button" class="pw-eye" onclick="togglePw('pwInput','eye1')" id="eye1">👁️</button>
            </div>
            <div class="pw-reqs" id="pwReqs">
                <div class="pw-reqs-title">Password must have:</div>
                <div class="req unmet" id="req-len">  <span class="req-icon">○</span> At least 8 characters</div>
                <div class="req unmet" id="req-upper"><span class="req-icon">○</span> One uppercase letter (A–Z)</div>
                <div class="req unmet" id="req-lower"><span class="req-icon">○</span> One lowercase letter (a–z)</div>
                <div class="req unmet" id="req-num">  <span class="req-icon">○</span> One number (0–9)</div>
                <div class="req unmet" id="req-sym">  <span class="req-icon">○</span> One special character (!@#$…)</div>
            </div>
        </div>

        <div class="field">
            <label>Confirm Password</label>
            <div class="pw-wrap">
                <input type="password" name="confirmPassword" id="confirmInput"
                       placeholder="Repeat your password" required autocomplete="new-password"
                       oninput="checkConfirm()">
                <button type="button" class="pw-eye" onclick="togglePw('confirmInput','eye2')" id="eye2">👁️</button>
            </div>
            <div class="match-msg" id="matchMsg"></div>
        </div>

        <!-- ── SECURITY QUESTION ── -->
        <div class="section-divider">Account Recovery</div>

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

        <div class="field">
            <label>Your Answer</label>
            <input type="text" name="securityAnswer" id="secAnswer"
                   placeholder="Answer (case-insensitive)" required autocomplete="off"
                   oninput="updateSubmit()">
        </div>

        <button type="submit" class="btn-submit" id="submitBtn" disabled>Create Account</button>
    </form>

    <div class="divider">or</div>
    <div class="card-footer">Already have an account? <a href="login.jsp">Sign in</a></div>

</div>

<script>
    var html = document.documentElement;

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

    function togglePw(inputId, btnId) {
        var input = document.getElementById(inputId);
        var btn   = document.getElementById(btnId);
        var hide  = input.type === 'password';
        input.type      = hide ? 'text' : 'password';
        btn.textContent = hide ? '🙈' : '👁️';
    }

    var rules = {
        'req-len':   function(v){ return v.length >= 8; },
        'req-upper': function(v){ return /[A-Z]/.test(v); },
        'req-lower': function(v){ return /[a-z]/.test(v); },
        'req-num':   function(v){ return /\d/.test(v); },
        'req-sym':   function(v){ return /[^a-zA-Z0-9]/.test(v); },
    };

    var pwAllMet = false;
    var confirmOk = false;

    function checkPassword() {
        var val  = document.getElementById('pwInput').value;
        var reqs = document.getElementById('pwReqs');
        reqs.classList.toggle('visible', val.length > 0);

        var allMet = true;
        for (var id in rules) {
            var met = rules[id](val);
            var el  = document.getElementById(id);
            el.className = 'req ' + (met ? 'met' : 'unmet');
            el.querySelector('.req-icon').textContent = met ? '✓' : '○';
            if (!met) allMet = false;
        }
        pwAllMet = allMet;
        document.getElementById('pwInput').className = val.length === 0 ? '' : (allMet ? 'valid' : 'invalid');
        if (document.getElementById('confirmInput').value.length > 0) checkConfirm();
        updateSubmit();
    }

    function checkConfirm() {
        var pw  = document.getElementById('pwInput').value;
        var cfm = document.getElementById('confirmInput').value;
        var msg = document.getElementById('matchMsg');
        var inp = document.getElementById('confirmInput');
        if (cfm.length === 0) {
            msg.className = 'match-msg'; inp.className = ''; confirmOk = false;
        } else if (pw === cfm) {
            msg.className = 'match-msg ok'; msg.textContent = '✓ Passwords match';
            inp.className = 'valid'; confirmOk = true;
        } else {
            msg.className = 'match-msg bad'; msg.textContent = '✗ Passwords do not match';
            inp.className = 'invalid'; confirmOk = false;
        }
        updateSubmit();
    }

    function updateSubmit() {
        var username  = document.getElementById('usernameInput').value.trim();
        var secQ      = document.getElementById('secQuestion').value;
        var secA      = document.getElementById('secAnswer').value.trim();
        document.getElementById('submitBtn').disabled =
            !(pwAllMet && confirmOk && username.length > 0 && secQ !== '' && secA.length > 0);
    }

    document.getElementById('usernameInput').addEventListener('input', updateSubmit);
</script>
</body>
</html>