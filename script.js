// Frontend data storage (in-memory for demonstration)
let users = {}; // Dynamic user storage
let admins = {}; // Dynamic admin storage

let transactions = [];
let currentUser = null;
let currentRole = null;

const incomeCategories = ['Salary', 'Freelance', 'Investment', 'Business', 'Gift', 'Other Income'];
const expenseCategories = ['Food', 'Transportation', 'Housing', 'Utilities', 'Entertainment', 'Healthcare', 'Shopping', 'Education', 'Other Expense'];

// UI Navigation Functions
function showUserLogin() {
    hideAllSections();
    document.getElementById('userLoginPage').classList.add('active');
    // document.getElementById('mainContainer').className = 'container';
                document.body.classList.remove('dashboard-active');
}

function showUserSignup() {
    hideAllSections();
    document.getElementById('userSignupPage').classList.add('active');
    // document.getElementById('mainContainer').className = 'container';
                document.body.classList.remove('dashboard-active');
}

function showAdminLogin() {
    hideAllSections();
    document.getElementById('adminLoginPage').classList.add('active');
   
                document.body.classList.remove('dashboard-active');
}

function hideAllSections() {
    const sections = document.querySelectorAll('.page-section');
    sections.forEach(section => section.classList.remove('active'));
}

// UI Helper Functions
function updateCategoryDropdown() {
    const select = document.getElementById('transactionCategory');
    const type = document.getElementById('transactionType').value;
    
    select.innerHTML = '<option value="">Select category</option>';
    const categories = type === 'income' ? incomeCategories : expenseCategories;
    
    categories.forEach(cat => {
        const option = document.createElement('option');
        option.value = cat;
        option.textContent = cat;
        select.appendChild(option);
    });
}

// Event Listeners
document.addEventListener('DOMContentLoaded', function() {
    const transactionType = document.getElementById('transactionType');
    if (transactionType) {
        transactionType.addEventListener('change', updateCategoryDropdown);
    }
    showUserLogin();
});

// Login Functions
function userLogin() {
    const username = document.getElementById('userUsername').value.trim();
    const password = document.getElementById('userPassword').value.trim();

    if (!username || !password) {
        alert('Please enter both username and password');
        return;
    }

    // Check if user exists
    if (!users[username]) {
        alert('Username not found. Please sign up first or check your username.');
        return;
    }
    
    // Verify password
    if (users[username].password !== password) {
        alert('Invalid password. Please try again.');
        return;
    }

    currentUser = username;
    currentRole = 'user';
    showUserDashboard();
}

function userSignup() {
    const fullName = document.getElementById('signupFullName').value.trim();
    const email = document.getElementById('signupEmail').value.trim();
    const username = document.getElementById('signupUsername').value.trim();
    const password = document.getElementById('signupPassword').value.trim();
    const confirmPassword = document.getElementById('signupConfirmPassword').value.trim();

    // Validation
    if (!fullName || !email || !username || !password || !confirmPassword) {
        alert('Please fill in all fields');
        return;
    }

    if (username.length < 3) {
        alert('Username must be at least 3 characters long');
        return;
    }

    if (password.length < 6) {
        alert('Password must be at least 6 characters long');
        return;
    }

    if (password !== confirmPassword) {
        alert('Passwords do not match');
        return;
    }

    // Check if username already exists
    if (users[username]) {
        alert('Username already exists. Please choose a different username.');
        return;
    }

    // Check if email already exists
    const existingUser = Object.values(users).find(user => user.email === email);
    if (existingUser) {
        alert('Email address already registered. Please use a different email.');
        return;
    }

    // Basic email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        alert('Please enter a valid email address');
        return;
    }

    // Create new user
    users[username] = {
        password: password,
        name: fullName,
        email: email,
        joinDate: new Date().toISOString().split('T')[0]
    };

    // Clear form
    document.getElementById('signupFullName').value = '';
    document.getElementById('signupEmail').value = '';
    document.getElementById('signupUsername').value = '';
    document.getElementById('signupPassword').value = '';
    document.getElementById('signupConfirmPassword').value = '';

    alert('✅ Account created successfully! You can now login with your credentials.');
    showUserLogin();
}

function adminLogin() {
    const username = document.getElementById('adminUsername').value.trim();
    const password = document.getElementById('adminPassword').value.trim();

    if (!username || !password) {
        alert('Please enter both admin ID and password');
        return;
    }

    // Create admin if doesn't exist, or verify if exists
    if (!admins[username]) {
        // Create new admin
        admins[username] = {
            password: password,
            name: username.charAt(0).toUpperCase() + username.slice(1) + ' (Admin)'
        };
    } else {
        // Verify existing admin password
        if (admins[username].password !== password) {
            alert('Invalid password for this admin ID');
            return;
        }
    }

    currentUser = username;
    currentRole = 'admin';
    showAdminDashboard();
}

function logout() {
    currentUser = null;
    currentRole = null;
    
    // Clear all form fields
    document.getElementById('userUsername').value = '';
    document.getElementById('userPassword').value = '';
    document.getElementById('signupFullName').value = '';
    document.getElementById('signupEmail').value = '';
    document.getElementById('signupUsername').value = '';
    document.getElementById('signupPassword').value = '';
    document.getElementById('signupConfirmPassword').value = '';
    document.getElementById('adminUsername').value = '';
    document.getElementById('adminPassword').value = '';
    
    showUserLogin();
}

// Dashboard Display Functions
function showUserDashboard() {
    hideAllSections();
    document.getElementById('userDashboard').classList.add('active');
    document.body.classList.add('dashboard-active');
    document.getElementById('currentUser').textContent = users[currentUser].name;
    updateCategoryDropdown();
    updateUserStats();
    displayUserTransactions();
}

function showAdminDashboard() {
    hideAllSections();
    document.getElementById('adminDashboard').classList.add('active');
    document.body.classList.add('dashboard-active');
    document.getElementById('currentAdmin').textContent = admins[currentUser].name;
    updateAdminStats();
    displayAdminTransactions();
    populateUserFilter();
}

// Transaction Management Functions
function addTransaction() {
    const type = document.getElementById('transactionType').value;
    const amount = parseFloat(document.getElementById('transactionAmount').value);
    const category = document.getElementById('transactionCategory').value;
    const description = document.getElementById('transactionDescription').value;

    if (!amount || amount <= 0) {
        alert('Please enter a valid amount greater than 0');
        return;
    }

    if (!category) {
        alert('Please select a category');
        return;
    }

    if (!description.trim()) {
        alert('Please enter a description');
        return;
    }

    const transaction = {
        id: Date.now(),
        user: currentUser,
        type: type,
        amount: amount,
        category: category,
        description: description.trim(),
        date: new Date().toISOString().split('T')[0],
        timestamp: new Date()
    };

    transactions.push(transaction);

    // Clear form
    document.getElementById('transactionAmount').value = '';
    document.getElementById('transactionCategory').value = '';
    document.getElementById('transactionDescription').value = '';

    updateUserStats();
    displayUserTransactions();

    alert('✅ Transaction added successfully!');
}

// Statistics Display Functions
function updateUserStats() {
    const userTransactions = transactions.filter(t => t.user === currentUser);
    
    const totalIncome = userTransactions
        .filter(t => t.type === 'income')
        .reduce((sum, t) => sum + t.amount, 0);
    
    const totalExpenses = userTransactions
        .filter(t => t.type === 'expense')
        .reduce((sum, t) => sum + t.amount, 0);
    
    const netBalance = totalIncome - totalExpenses;

    document.getElementById('totalIncome').textContent = `$${totalIncome.toFixed(2)}`;
    document.getElementById('totalExpenses').textContent = `$${totalExpenses.toFixed(2)}`;
    document.getElementById('netBalance').textContent = `$${netBalance.toFixed(2)}`;
}

function updateAdminStats() {
    const totalUsers = Object.keys(users).length;
    const totalTransactions = transactions.length;
    
    const systemIncome = transactions
        .filter(t => t.type === 'income')
        .reduce((sum, t) => sum + t.amount, 0);
    
    const systemExpenses = transactions
        .filter(t => t.type === 'expense')
        .reduce((sum, t) => sum + t.amount, 0);
    
    const systemTotal = systemIncome - systemExpenses;

    document.getElementById('totalUsers').textContent = totalUsers;
    document.getElementById('totalTransactions').textContent = totalTransactions;
    document.getElementById('systemTotal').textContent = `$${systemTotal.toFixed(2)}`;
}

// Transaction Display Functions
function displayUserTransactions() {
    const userTransactions = transactions
        .filter(t => t.user === currentUser)
        .sort((a, b) => b.timestamp - a.timestamp);

    const container = document.getElementById('userTransactionsList');
    container.innerHTML = '';

    userTransactions.forEach(transaction => {
        const row = document.createElement('div');
        row.className = 'table-row';
        row.innerHTML = `
            <div>${transaction.date}</div>
            <div class="${transaction.type}">${transaction.type.toUpperCase()}</div>
            <div class="${transaction.type}">$${transaction.amount.toFixed(2)}</div>
            <div>${transaction.description}</div>
            <div>${transaction.category}</div>
        `;
        container.appendChild(row);
    });

    if (userTransactions.length === 0) {
        container.innerHTML = '<div style="padding: 2rem; text-align: center; color: #666;">No transactions yet. Add your first transaction above!</div>';
    }
}

function displayAdminTransactions() {
    const filteredTransactions = getFilteredTransactions();
    const container = document.getElementById('adminTransactionsList');
    container.innerHTML = '';

    filteredTransactions.forEach(transaction => {
        const row = document.createElement('div');
        row.className = 'table-row admin-table';
        row.innerHTML = `
            <div>${transaction.date}</div>
            <div><strong>${users[transaction.user] ? users[transaction.user].name : transaction.user}</strong></div>
            <div class="${transaction.type}">${transaction.type.toUpperCase()}</div>
            <div class="${transaction.type}">$${transaction.amount.toFixed(2)}</div>
            <div>${transaction.description}</div>
            <div>${transaction.category}</div>
        `;
        container.appendChild(row);
    });

    if (filteredTransactions.length === 0) {
        container.innerHTML = '<div style="padding: 2rem; text-align: center; color: #666;">No transactions found matching the current filters.</div>';
    }
}

// Filter Functions
function populateUserFilter() {
    const select = document.getElementById('userFilter');
    select.innerHTML = '<option value="">All Users</option>';
    
    Object.keys(users).forEach(username => {
        const option = document.createElement('option');
        option.value = username;
        option.textContent = users[username].name;
        select.appendChild(option);
    });
}

function getFilteredTransactions() {
    const userFilter = document.getElementById('userFilter').value;
    const typeFilter = document.getElementById('typeFilter').value;
    
    return transactions
        .filter(t => !userFilter || t.user === userFilter)
        .filter(t => !typeFilter || t.type === typeFilter)
        .sort((a, b) => b.timestamp - a.timestamp);
}

function applyFilters() {
    displayAdminTransactions();
}

// Keyboard Event Support
document.addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
        const activeSection = document.querySelector('.page-section.active');
        if (activeSection) {
            if (activeSection.id === 'userLoginPage') {
                userLogin();
            } else if (activeSection.id === 'userSignupPage') {
                userSignup();
            } else if (activeSection.id === 'adminLoginPage') {
                adminLogin();
            }
        }
    }
});