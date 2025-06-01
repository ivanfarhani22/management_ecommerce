document.addEventListener('DOMContentLoaded', function() {
    // === 1. Mengambil Elemen DOM ===
    const chatbotButton = document.getElementById('chatbot-button');
    const chatbotContainer = document.getElementById('chatbot-container');
    const chatbotMessages = document.getElementById('chatbot-messages');
    const chatbotInput = document.getElementById('chatbot-input');
    const chatbotSend = document.getElementById('chatbot-send');
    const chatbotClose = document.getElementById('chatbot-close');
    // Elemen quickRepliesContainer tidak lagi digunakan secara aktif oleh JS ini
    // const quickRepliesContainer = document.getElementById('chatbot-quick-replies-container');

    // === 2. Data & Konfigurasi ===
    // quickReplySuggestions dihapus
    let isProcessing = false; // Status untuk mencegah pengiriman ganda
    let chatInitialized = false; // Status untuk welcome message

    // === 3. Fungsi Utama Chatbot ===

    // Fungsi updateQuickReplies() dihapus

    /** Menampilkan pesan selamat datang saat chatbot dibuka pertama kali. */
    function showWelcomeMessage() {
        const welcomeMessages = [
            "👋 Halo! Saya asisten virtual Digital Ecommerce. Ada yang bisa saya bantu hari ini?",
            "🤖 Selamat datang! Saya siap membantu Anda dengan informasi pesanan, produk, atau apapun tentang toko kami.",
            "😊 Hi! Butuh bantuan? Saya bisa membantu lacak pesanan, cari produk, atau kasih rekomendasi terbaik!"
        ];
        const randomWelcome = welcomeMessages[Math.floor(Math.random() * welcomeMessages.length)];
        addBotMessage(randomWelcome);

        setTimeout(() => {
            addBotMessage("💡 <strong>Quick help:</strong> Ketik hal seperti \"lacak pesanan 12345\", \"produk terlaris\", atau \"promo apa saja?\"");
            // Panggilan ke updateQuickReplies() dihapus
        }, 1000);
        chatInitialized = true; // Tandai bahwa chat sudah diinisialisasi
    }

    /**
     * Mengatur status UI (mengaktifkan/menonaktifkan input & tombol).
     * @param {boolean} processing Apakah sedang memproses pesan?
     */
    function setProcessingState(processing) {
        isProcessing = processing;
        chatbotSend.disabled = processing;
        chatbotInput.disabled = processing;

        if (processing) {
            chatbotSend.innerHTML = '⏳'; // Ikon loading
            chatbotSend.classList.add('opacity-50', 'cursor-not-allowed');
            chatbotSend.classList.remove('hover:bg-gray-800');
        } else {
            // Mengembalikan ikon send (sesuaikan jika ikon Anda berbeda)
            chatbotSend.innerHTML = `<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"/></svg>`;
            chatbotSend.classList.remove('opacity-50', 'cursor-not-allowed');
            chatbotSend.classList.add('hover:bg-gray-800');
        }
    }

    /** Fungsi inti untuk mengirim pesan. */
    function _sendMessageCore() {
        const message = chatbotInput.value.trim();
        if (message === '') return;

        addUserMessage(message);
        chatbotInput.value = '';
        chatbotInput.style.height = 'auto'; // Reset tinggi input
        showTypingIndicator();
        // Panggilan ke updateQuickReplies('none') dihapus

        sendMessageToServer(message)
            .then(data => {
                handleServerResponse(data, message);
            })
            .catch(error => {
                console.error('Chatbot Error:', error);
                addBotMessage("🔄 Ups, saya sedang mengalami sedikit gangguan. Coba kirim pesan lagi dalam beberapa detik ya!");
                addRetryOption(message);
            })
            .finally(() => {
                removeTypingIndicator();
                setProcessingState(false);
            });
    }

    /** Wrapper untuk `sendMessage` yang mengelola `isProcessing`. */
    function sendMessage() {
        if (isProcessing) return;
        setProcessingState(true);
        _sendMessageCore();
    }

    /**
     * Mengirim pesan ke backend Laravel (/chatbot) dengan mekanisme retry.
     * @param {string} message Pesan pengguna.
     * @param {number} retryCount Jumlah percobaan ulang.
     * @returns {Promise<object>} Data respons dari server.
     */
    async function sendMessageToServer(message, retryCount = 0) {
        const maxRetries = 2;
        try {
            const response = await fetch('/chatbot', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                },
                body: JSON.stringify({ message: message }) // Hanya kirim 'message'
            });

            if (!response.ok) {
                let errorBody = await response.text();
                throw new Error(`Server responded with ${response.status}. Body: ${errorBody}`);
            }
            return await response.json();
        } catch (error) {
            if (retryCount < maxRetries) {
                console.log(`Retrying... (${retryCount + 1}/${maxRetries})`);
                await new Promise(resolve => setTimeout(resolve, 1000 * (retryCount + 1)));
                return sendMessageToServer(message, retryCount + 1);
            }
            throw error;
        }
    }

    /**
     * Menangani respons dari server dan menampilkannya.
     * @param {object} data Respons dari server.
     * @param {string} originalMessage Pesan asli pengguna.
     */
    function handleServerResponse(data, originalMessage) {
        if (!data || !data.type) {
            addBotMessage("Maaf, saya tidak mengerti respons dari server.");
            addRetryOption(originalMessage);
            return;
        }

        if (data.type === 'text') {
            addBotMessage(data.content);
        } else if (data.type === 'product_suggestion' && data.products) {
            addBotMessage(data.content);
            addProductCarousel(data.products);
        } else if (data.type === 'order_status') {
            addBotMessage(data.content);
            addQuickAction('Lacak pesanan lain', 'Lacak pesanan');
        } else if (data.type === 'error') {
            addBotMessage(`😕 Maaf, terjadi kesalahan: ${data.content}`);
        } else {
            addBotMessage(data.content || "Saya tidak yakin bagaimana meresponsnya.");
        }
        // Semua panggilan ke updateQuickReplies() dihapus dari sini
    }

    // === 4. Fungsi Tampilan (UI Helpers) ===

    /** Menambahkan pesan pengguna ke UI. */
    function addUserMessage(message) {
        const messageElement = document.createElement('div');
        messageElement.className = 'flex justify-end mb-4';
        messageElement.innerHTML = `
            <div class="bg-blue-500 text-white rounded-lg py-2 px-4 max-w-[70%] shadow-sm">
                <p class="text-sm">${escapeHTML(message)}</p>
                <span class="text-xs opacity-75">${new Date().toLocaleTimeString('id-ID', {hour: '2-digit', minute: '2-digit'})}</span>
            </div>
        `;
        chatbotMessages.appendChild(messageElement);
        scrollToBottom();
    }

    /** Menambahkan pesan bot ke UI. */
    function addBotMessage(message) {
        const messageElement = document.createElement('div');
        messageElement.className = 'flex mb-4';
        let formattedMessage = escapeHTML(message)
            .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
            .replace(/_(.*?)_/g, '<em>$1</em>')
            .replace(/\n/g, '<br>');
        messageElement.innerHTML = `
            <div class="flex items-start space-x-2">
                <div class="flex-shrink-0 w-8 h-8 bg-black rounded-full flex items-center justify-center text-white">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"/></svg>
                </div>
                <div class="bg-gray-100 rounded-lg py-3 px-4 max-w-[70%] shadow-sm">
                    <div class="text-sm text-gray-800">${formattedMessage}</div>
                    <span class="text-xs text-gray-500 mt-1 block">${new Date().toLocaleTimeString('id-ID', {hour: '2-digit', minute: '2-digit'})}</span>
                </div>
            </div>
        `;
        chatbotMessages.appendChild(messageElement);
        scrollToBottom();
    }

    /** Menampilkan indikator bot sedang mengetik. */
    function showTypingIndicator() {
        if (document.getElementById('typing-indicator')) return;
        const indicatorElement = document.createElement('div');
        indicatorElement.id = 'typing-indicator';
        indicatorElement.className = 'flex mb-4';
        indicatorElement.innerHTML = `
            <div class="flex items-start space-x-2">
                <div class="flex-shrink-0 w-8 h-8 bg-black rounded-full flex items-center justify-center text-white">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"/></svg>
                </div>
                <div class="bg-gray-100 rounded-lg py-3 px-4 flex items-center space-x-1">
                    <div class="flex space-x-1">
                        <div class="w-2 h-2 bg-gray-500 rounded-full animate-bounce"></div>
                        <div class="w-2 h-2 bg-gray-500 rounded-full animate-bounce" style="animation-delay: 0.1s"></div>
                        <div class="w-2 h-2 bg-gray-500 rounded-full animate-bounce" style="animation-delay: 0.2s"></div>
                    </div>
                </div>
            </div>
        `;
        chatbotMessages.appendChild(indicatorElement);
        scrollToBottom();
    }

    /** Menghapus indikator bot sedang mengetik. */
    function removeTypingIndicator() {
        const indicator = document.getElementById('typing-indicator');
        if (indicator) indicator.remove();
    }

    /** Menambahkan carousel produk (jika backend mengirimnya). */
    function addProductCarousel(products) {
        // Implementasi carousel (sama seperti di respons sebelumnya)
        // ... (Tambahkan kode addProductCarousel dari respons sebelumnya jika diperlukan) ...
        addBotMessage("Maaf, tampilan carousel produk belum diimplementasikan sepenuhnya di sini.");
    }

    /** Menambahkan tombol aksi cepat. */
    function addQuickAction(label, value) {
        const actionElement = document.createElement('div');
        actionElement.className = 'flex justify-center mb-4';
        const button = document.createElement('button');
        button.className = 'bg-blue-500 hover:bg-blue-600 text-white text-sm px-4 py-2 rounded-lg transition-colors duration-200';
        button.textContent = label;
        button.onclick = function() {
            chatbotInput.value = value;
            sendMessage();
            actionElement.remove();
        };
        actionElement.appendChild(button);
        chatbotMessages.appendChild(actionElement);
        scrollToBottom();
    }

    /** Menambahkan tombol coba lagi. */
    function addRetryOption(originalMessage) {
        const retryElement = document.createElement('div');
        retryElement.className = 'flex justify-center mb-4';
        const button = document.createElement('button');
        button.className = 'bg-orange-500 hover:bg-orange-600 text-white text-sm px-4 py-2 rounded-lg transition-colors duration-200';
        button.innerHTML = '🔄 Coba Kirim Lagi';
        button.onclick = function() {
            retryElement.remove();
            chatbotInput.value = originalMessage;
            sendMessage();
        };
        retryElement.appendChild(button);
        chatbotMessages.appendChild(retryElement);
        scrollToBottom();
    }

    /** Menggulir chat ke bawah. */
    function scrollToBottom() {
        chatbotMessages.scrollTo({ top: chatbotMessages.scrollHeight, behavior: 'smooth' });
    }

    /** Mengamankan string HTML. */
    function escapeHTML(text) {
        if (typeof text !== 'string') return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    // === 5. Event Listeners & Inisialisasi ===

    // Toggle chatbot
    chatbotButton.addEventListener('click', function() {
        chatbotContainer.classList.toggle('hidden');
        if (!chatInitialized && !chatbotContainer.classList.contains('hidden')) {
            showWelcomeMessage();
        }
        if (!chatbotContainer.classList.contains('hidden')) {
            chatbotInput.focus();
        }
    });

    // Tombol tutup
    chatbotClose.addEventListener('click', () => chatbotContainer.classList.add('hidden'));

    // Tombol kirim
    chatbotSend.addEventListener('click', sendMessage);

    // Kirim dengan Enter
    chatbotInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });

    // Input auto-resize
    chatbotInput.addEventListener('input', function() {
        this.style.height = 'auto';
        this.style.height = (this.scrollHeight) + 'px';
    });

    // Mencegah submit form (jika input ada di dalam form)
    const chatForm = chatbotInput.closest('form');
    if (chatForm) {
        chatForm.addEventListener('submit', (e) => e.preventDefault());
    }

    // Keyboard shortcuts
    document.addEventListener('keydown', function(e) {
        if (e.altKey && (e.key === 'c' || e.key === 'C')) {
            e.preventDefault();
            chatbotButton.click();
        }
        if (e.key === 'Escape' && !chatbotContainer.classList.contains('hidden')) {
            chatbotClose.click();
        }
    });

}); // Akhir dari DOMContentLoaded