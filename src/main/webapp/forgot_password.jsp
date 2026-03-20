<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <title>Forgot Password | Palestine Relief</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,400;0,600;1,400&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        [data-theme="dark"] { --bg:#0b0e14; --surface:#13171f; --surface2:#1a1f2b; --border:rgba(255,255,255,0.07); --text:#e6e8f0; --text2:#9ba3b8; --muted:#5a6278; --shadow:rgba(0,0,0,0.5); }
        [data-theme="light"] { --bg:#f2f4f8; --surface:#ffffff; --surface2:#f7f8fc; --border:rgba(0,0,0,0.08); --text:#181c2a; --text2:#4a5068; --muted:#9ba3b8; --shadow:rgba(0,0,0,0.08); }
        :root { --green:#1db954; --green-dim:rgba(29,185,84,0.12); --red:#e63946; --gold:#f4a261; }

        body { font-family:'DM Sans',sans-serif; background:var(--bg); color:var(--text); min-height:100vh; display:flex; align-items:center; justify-content:center; transition:background .25s,color .25s; position:relative; overflow-x:hidden; padding:40px 20px; }
        body::before { content:''; position:fixed; inset:0; background-image:radial-gradient(circle at 20% 30%,rgba(29,185,84,0.06) 0%,transparent 50%),radial-gradient(circle at 80% 70%,rgba(244,162,97,0.04) 0%,transparent 50%); pointer-events:none; }
        body::after { content:'🇵🇸'; position:fixed; bottom:-40px; right:-20px; font-size:220px; opacity:.03; pointer-events:none; transform:rotate(-12deg); }

        .theme-btn { position:fixed; top:20px; right:20px; width:36px; height:36px; border-radius:9px; background:var(--surface); border:1px solid var(--border); cursor:pointer; font-size:16px; display:flex; align-items:center; justify-content:center; transition:border-color .2s,background .25s; z-index:10; }
        .theme-btn:hover { border-color:var(--green); }

        .card { background:var(--surface); border:1px solid var(--border); border-radius:16px; padding:40px 36px; width:100%; max-width:420px; box-shadow:0 8px 40px var(--shadow); animation:fadeUp .45s ease both; transition:background .25s,border-color .25s; }

        .brand { display:flex; align-items:center; gap:10px; justify-content:center; margin-bottom:28px; }
        .brand-icon { width:38px; height:38px; border-radius:10px; background:var(--green-dim); border:1px solid rgba(29,185,84,0.25); display:flex; align-items:center; justify-content:center; font-size:19px; }
        .brand-name { font-family:'Lora',serif; font-size:19px; font-weight:600; }
        .brand-name span { color:var(--green); }

        .card-title { font-family:'Lora',serif; font-size:22px; font-weight:600; text-align:center; margin-bottom:4px; }
        .card-sub { font-size:13px; color:var(--muted); text-align:center; margin-bottom:28px; line-height:1.6; }

        .step-indicator { display:flex; align-items:center; gap:0; margin-bottom:28px; }
        .step { flex:1; text-align:center; font-size:12px; font-weight:600; padding:8px; border-bottom:2px solid var(--border); color:var(--muted); transition:all .2s; }
        .step.active { color:var(--green); border-bottom-color:var(--green); }
        .step.done { color:var(--green); border-bottom-color:var(--green); opacity:.5; }

        .field { display:flex; flex-direction:column; gap:6px; margin-bottom:14px; }
        .field label { font-size:11.5px; font-weight:600; text-transform:uppercase; letter-spacing:.7px; color:var(--muted); }
        .field input { background:var(--surface2); border:1px solid var(--border); color:var(--text); padding:11px 14px; border-radius:8px; font-size:14px; font-family:inherit; outline:none; width:100%; transition:border-color .18s,box-shadow .18s,background .25s; }
        .field input::placeholder { color:var(--muted); }
        .field input:focus { border-color:var(--green); box-shadow:0 0 0 3px rgba(29,185,84,0.1); }
        .field input.valid { border-color:var(--green); }
        .field input.invalid { border-color:var(--red); box-shadow:0 0 0 3px rgba(230,57,70,0.08); }

        .question-box { background:var(--surface2); border:1px solid rgba(29,185,84,0.2); border-radius:8px; padding:12px 16px; margin-bottom:14px; font-size:13.5px; color:var(--text2); line-height:1.5; }
        .question-box strong { display:block; font-size:11px; text-transform:uppercase; letter-spacing:.7px; color:var(--green); margin-bottom:5px; }

        .pw-wrap { position:relative; }
        .pw-wrap input { padding-right:42px; }
        .pw-eye { position:absolute; right:12px; top:50%; transform:translateY(-50%); cursor:pointer; font-size:15px; opacity:.5; transition:opacity .18s; background:none; border:none; padding:0; }
        .pw-eye:hover { opacity:1; }

        .pw-reqs { background:var(--surface2); border:1px solid var(--border); border-radius:8px; padding:12px 14px; margin-top:6px; display:none; }
        .pw-reqs.visible { display:block; }
        .pw-reqs-title { font-size:11px; text-transform:uppercase; letter-spacing:.7px; color:var(--muted); margin-bottom:8px; font-weight:600; }
        .req { display:flex; align-items:center; gap:8px; font-size:12.5px; color:var(--muted); padding:3px 0; transition:color .2s; }
        .req-icon { font-size:13px; width:16px; text-align:center; flex-shrink:0; }
        .req.met { color:var(--green); }

        .match-msg { font-size:12px; margin-top:5px; display:none; }
        .match-msg.ok  { color:var(--green); display:block; }
        .match-msg.bad { color:var(--red);   display:block; }

        .btn-submit { width:100%; background:var(--green); color:#051a0d; border:none; padding:12px; border-radius:8px; font-size:14.5px; font-weight:700; cursor:pointer; font-family:inherit; transition:opacity .18s,transform .1s; margin-top:6px; }
        .btn-submit:hover { opacity:.88; transform:translateY(-1px); }
        .btn-submit:active { transform:translateY(0); }
        .btn-submit:disabled { opacity:.4; cursor:not-allowed; transform:none; }

        .error-box { display:flex; align-items:center; gap:8px; background:rgba(230,57,70,0.08); border:1px solid rgba(230,57,70,0.25); border-radius:8px; padding:10px 14px; margin-bottom:16px; animation:shake .35s ease; }
        .error-box span { font-size:13px; color:var(--red); }

        .divider { display:flex; align-items:center; gap:10px; margin:20px 0; color:var(--muted); font-size:12px; }
        .divider::before, .divider::after { content:''; flex:1; height:1px; background:var(--border); }
        .card-footer { text-align:center; font-size:13px; color:var(--muted); }
        .card-footer a { color:var(--green); text-decoration:none; font-weight:500; }
        .card-footer a:hover { text-decoration:underline; }

        @keyframes fadeUp { from{opacity:0;transform:translateY(16px);}to{opacity:1;transform:none;} }
        @keyframes shake  { 0%,100%{transform:translateX(0);}25%{transform:translateX(-6px);}75%{transform:translateX(6px);} }
    </style>
</head>
<body>

<button class="theme-btn" onclick="toggleTheme()" id="themeBtn">🌙</button>

<%
    String step     = request.getParameter("step");
    String username = request.getParameter("username");
    String question = request.getParameter("question");
    String error    = request.getParameter("error");
    if (step == null) step = "1";

    java.util.Map<String,String> questionMap = new java.util.LinkedHashMap<>();
    questionMap.put("pet",    "What was the name of your first pet?");
    questionMap.put("city",   "What city were you born in?");
    questionMap.put("mother", "What is your mother's maiden name?");
    questionMap.put("school", "What was the name of your primary school?");
    questionMap.put("friend", "What is the name of your childhood best friend?");
    String questionText = questionMap.getOrDefault(question != null ? question : "", question != null ? question : "");
%>

<div class="card">
    <div class="brand">
        <div class="brand-name">Palestine <span>Relief</span></div>
    </div>

    <div class="card-title">Reset Password</div>
    <div class="card-sub">
        <% if("1".equals(step)) { %>Verify your identity to reset your password.<% } %>
        <% if("2".equals(step)) { %>Answer your security question and set a new password.<% } %>
    </div>

    <div class="step-indicator">
        <div class="step <%= "1".equals(step) ? "active" : "done" %>">① Identify</div>
        <div class="step <%= "2".equals(step) ? "active" : "" %>">② Reset</div>
    </div>

    <%
        String errorMsg = null;
        if ("nousername".equals(error)) errorMsg = "Please enter your username.";
        else if ("notfound".equals(error))    errorMsg = "No account found with that username.";
        else if ("wronganswer".equals(error)) errorMsg = "Incorrect answer. Please try again.";
        else if ("mismatch".equals(error))    errorMsg = "Passwords do not match.";
        else if ("weak".equals(error))        errorMsg = "Password does not meet the requirements.";
        else if ("missing".equals(error))     errorMsg = "Please fill in all fields.";
        else if ("database".equals(error))    errorMsg = "A database error occurred. Please try again.";
        if (errorMsg != null) {
    %>
    <div class="error-box"><span><%= errorMsg %></span></div>
    <% } %>

    <% if ("1".equals(step)) { %>
    <!-- STEP 1: Enter username -->
    <form action="forgotPassword" method="post">
        <input type="hidden" name="step" value="1">
        <div class="field">
            <label>Username</label>
            <input type="text" name="username" placeholder="Enter your username" required autofocus>
        </div>
        <button type="submit" class="btn-submit">Find My Account</button>
    </form>

    <% } else if ("2".equals(step)) { %>
    <!-- STEP 2: Answer + new password -->
    <form action="forgotPassword" method="post" id="resetForm">
        <input type="hidden" name="step" value="2">
        <input type="hidden" name="username" value="<%= username != null ? username : "" %>">

        <div class="question-box">
            <strong>Your Security Question</strong>
            <%= questionText %>
        </div>

        <div class="field">
            <label>Your Answer</label>
            <input type="text" name="answer" placeholder="Answer (case-insensitive)" required>
        </div>

        <div class="field">
            <label>New Password</label>
            <div class="pw-wrap">
                <input type="password" name="newPassword" id="pwInput"
                       placeholder="Create new password" required oninput="checkPassword()">
                <button type="button" class="pw-eye" onclick="togglePw('pwInput','eye1')" id="eye1">👁️</button>
            </div>
            <div class="pw-reqs" id="pwReqs">
                <div class="pw-reqs-title">Password must have:</div>
                <div class="req unmet" id="req-len">  <span class="req-icon">○</span> At least 8 characters</div>
                <div class="req unmet" id="req-upper"><span class="req-icon">○</span> One uppercase letter</div>
                <div class="req unmet" id="req-lower"><span class="req-icon">○</span> One lowercase letter</div>
                <div class="req unmet" id="req-num">  <span class="req-icon">○</span> One number</div>
                <div class="req unmet" id="req-sym">  <span class="req-icon">○</span> One special character</div>
            </div>
        </div>

        <div class="field">
            <label>Confirm New Password</label>
            <div class="pw-wrap">
                <input type="password" name="confirmNew" id="confirmInput"
                       placeholder="Repeat new password" required oninput="checkConfirm()">
                <button type="button" class="pw-eye" onclick="togglePw('confirmInput','eye2')" id="eye2">👁️</button>
            </div>
            <div class="match-msg" id="matchMsg"></div>
        </div>

        <button type="submit" class="btn-submit" id="submitBtn" disabled>Reset Password</button>
    </form>
    <% } %>

    <div class="divider">or</div>
    <div class="card-footer"><a href="login.jsp"> Back to Sign In</a></div>
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
        input.type = input.type === 'password' ? 'text' : 'password';
        btn.textContent = input.type === 'password' ? '👁️' : '🙈';
    }

    var rules = {
        'req-len':   function(v){ return v.length >= 8; },
        'req-upper': function(v){ return /[A-Z]/.test(v); },
        'req-lower': function(v){ return /[a-z]/.test(v); },
        'req-num':   function(v){ return /\d/.test(v); },
        'req-sym':   function(v){ return /[^a-zA-Z0-9]/.test(v); },
    };
    var pwAllMet = false, confirmOk = false;

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
        if (cfm.length === 0) { msg.className = 'match-msg'; inp.className = ''; confirmOk = false; }
        else if (pw === cfm)  { msg.className = 'match-msg ok'; msg.textContent = '✓ Passwords match'; inp.className = 'valid'; confirmOk = true; }
        else                  { msg.className = 'match-msg bad'; msg.textContent = '✗ Passwords do not match'; inp.className = 'invalid'; confirmOk = false; }
        updateSubmit();
    }
    function updateSubmit() {
        var btn = document.getElementById('submitBtn');
        if (btn) btn.disabled = !(pwAllMet && confirmOk);
    }
    (function() {
        var params = new URLSearchParams(window.location.search);
        if (params.get('msg') === 'pwreset') {
            var isDark = document.documentElement.getAttribute('data-theme') === 'dark';
            Swal.fire({
                background: isDark ? '#13171f' : '#ffffff',
                color:      isDark ? '#e6e8f0' : '#181c2a',
                icon: 'success',
                iconColor: '#1db954',
                title: 'Password Reset!',
                html: '<p style="font-size:14px;line-height:1.6;">Your password has been updated successfully.<br>Please sign in with your new password.</p>',
                confirmButtonColor: '#1db954',
                confirmButtonText: 'Go to Sign In',
            }).then(function() {
                window.location.href = 'login.jsp';
            });
            window.history.replaceState({}, document.title, window.location.pathname);
        }
    })();
</script>
</body>
</html>