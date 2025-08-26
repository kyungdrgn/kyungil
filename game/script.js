// 각 화면과 버튼 요소들을 가져오기
const gameSelectionScreen = document.getElementById('game-selection-screen');
const charadesGameScreen = document.getElementById('charades-game-screen');
const gameOverScreen = document.getElementById('game-over-screen');
const startButtonContainer = document.getElementById('start-button-container');
const startBtn = document.getElementById('start-btn');
const passBtn = document.getElementById('pass-btn');
const correctBtn = document.getElementById('correct-btn');
const endGameBtn = document.getElementById('end-game-btn');
const restartBtn = document.getElementById('restart-btn');
const scoreDisplay = document.getElementById('score');
const wordDisplay = document.getElementById('word-display');
const finalScoreDisplay = document.getElementById('final-score');

// 게임 상태 변수
let score = 0;
let words = []; // 현재 진행할 게임의 단어 목록이 담길 배열
let availableWords = [];
let selectedGame = '';

// --- 수정된 부분 1: 모든 게임 데이터를 저장할 변수 ---
let allGameData = {}; // JSON 파일의 모든 데이터를 저장

// 1. 게임 선택
document.querySelectorAll('.game-choice-btn').forEach(button => {
    button.addEventListener('click', (e) => {
        selectedGame = e.target.dataset.game;
        startButtonContainer.classList.remove('hidden');
    });
});

// JSON 파일에서 모든 단어 목록을 가져와서 allGameData에 저장
fetch('words.json')
    .then(response => response.json())
    .then(data => {
        allGameData = data; // 'charades'와 'consonant_quiz' 데이터를 모두 저장
    })
    .catch(error => console.error('단어를 불러오는 데 실패했습니다:', error));


// 새 단어를 화면에 표시하는 함수
function showNewWord() {
    if (availableWords.length === 0) {
        // 모든 단어를 다 썼으면 다시 채워넣기
        availableWords = [...words];
    }
    const randomIndex = Math.floor(Math.random() * availableWords.length);
    const newWord = availableWords[randomIndex];
    
    availableWords.splice(randomIndex, 1);
    
    wordDisplay.textContent = newWord;
}

// 점수 업데이트 함수
function updateScore() {
    scoreDisplay.textContent = score;
}

// 게임 시작 함수
function startGame() {
    // --- 수정된 부분 2: 게임 시작 시 선택된 게임에 맞는 단어 목록 설정 ---
    if (selectedGame === 'charades') {
        // '몸으로 말해요'를 선택한 경우
        words = allGameData.charades;
    } else if (selectedGame === 'consonant') {
        // '초성퀴즈'를 선택한 경우
        words = allGameData.consonant_quiz;
    } else {
        // 혹시 모를 예외 처리
        alert('게임을 선택해주세요!');
        return;
    }

    score = 0;
    availableWords = [...words]; // 사용 가능한 단어 목록 초기화
    updateScore();
    showNewWord();
    
    gameSelectionScreen.classList.add('hidden');
    gameOverScreen.classList.add('hidden');
    charadesGameScreen.classList.remove('hidden');
}

// 2. 시작 버튼 클릭 이벤트
startBtn.addEventListener('click', startGame);

// 3. 패스 버튼 클릭 이벤트
passBtn.addEventListener('click', showNewWord);

// 4. 정답 버튼 클릭 이벤트
correctBtn.addEventListener('click', () => {
    score++;
    updateScore();
    showNewWord();
});

// 5. 종료 버튼 클릭 이벤트
endGameBtn.addEventListener('click', () => {
    finalScoreDisplay.textContent = score;
    charadesGameScreen.classList.add('hidden');
    gameOverScreen.classList.remove('hidden');
});

// 돌아가기 버튼 클릭 이벤트
restartBtn.addEventListener('click', () => {
    gameOverScreen.classList.add('hidden');
    gameSelectionScreen.classList.remove('hidden');
    startButtonContainer.classList.add('hidden');
});