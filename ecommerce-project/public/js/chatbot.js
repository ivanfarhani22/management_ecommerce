document.addEventListener('DOMContentLoaded', function() {
    // Get elements
    const chatbotButton = document.getElementById('chatbot-button');
    const chatbotContainer = document.getElementById('chatbot-container');
    const chatbotMessages = document.getElementById('chatbot-messages');
    const chatbotInput = document.getElementById('chatbot-input');
    const chatbotSend = document.getElementById('chatbot-send');
    const chatbotClose = document.getElementById('chatbot-close');

    // Predefined quick reply suggestions yang lebih spesifik sesuai dengan intent NLP
    const quickReplySuggestions = [
        'Lacak pesanan saya', 
        'Produk laris bulan ini', 
        'Cari sepatu olahraga', 
        'Lihat semua kategori',
        'Info gratis ongkir', 
        'Promo diskon apa saja?',
        'Kebijakan retur',
        'Cara pembayaran'
    ];

    // Enhanced quick reply system with contextual suggestions
    function updateQuickReplies(context = 'default') {
        const quickRepliesContainer = document.querySelector('.px-4.py-2.bg-gray-50.flex') || 
                                    document.querySelector('.chatbot-quick-replies');
        
        if (!quickRepliesContainer) return;
        
        quickRepliesContainer.innerHTML = ''; // Clear existing buttons

        let suggestions = quickReplySuggestions;
        
        // Contextual suggestions based on conversation state
        if (context === 'order_tracking') {
            suggestions = ['Lacak pesanan 12345', 'Status pengiriman', 'Estimasi sampai kapan?'];
        } else if (context === 'product_search') {
            suggestions = ['Produk terlaris', 'Cari tas wanita', 'Lihat kategori fashion'];
        } else if (context === 'promotion') {
            suggestions = ['Diskon apa saja?', 'Cara pakai voucher', 'Cashback berapa?'];
        }

        suggestions.forEach(suggestion => {
            const button = document.createElement('button');
            button.textContent = suggestion;
            button.className = 'chatbot-quick-reply text-xs bg-gray-200 hover:bg-blue-100 rounded-full px-3 py-1 whitespace-nowrap transition-colors duration-200 border border-gray-300 hover:border-blue-300';
            button.addEventListener('click', function() {
                chatbotInput.value = suggestion;
                sendMessage();
            });
            quickRepliesContainer.appendChild(button);
        });
    }

    // Enhanced welcome message dengan personality yang lebih natural
    function showWelcomeMessage() {
        const welcomeMessages = [
            "👋 Halo! Saya asisten virtual Digital Ecommerce. Ada yang bisa saya bantu hari ini?",
            "🤖 Selamat datang! Saya siap membantu Anda dengan informasi pesanan, produk, atau apapun tentang toko kami.",
            "😊 Hi! Butuh bantuan? Saya bisa membantu lacak pesanan, cari produk, atau kasih rekomendasi terbaik!"
        ];
        
        const randomWelcome = welcomeMessages[Math.floor(Math.random() * welcomeMessages.length)];
        addBotMessage(randomWelcome);
        
        // Add quick help options
        setTimeout(() => {
            addBotMessage("💡 <strong>Quick help:</strong> Ketik hal seperti \"lacak pesanan 12345\", \"produk terlaris\", atau \"promo apa saja?\"");
            updateQuickReplies();
        }, 1000);
    }

    // Toggle chatbot visibility
    chatbotButton.addEventListener('click', function() {
        chatbotContainer.classList.toggle('hidden');
        
        // If opening chatbot and no messages yet, show welcome
        if (!chatbotContainer.classList.contains('hidden') && chatbotMessages.children.length === 0) {
            showWelcomeMessage();
        }
        
        // Focus on input when opening
        if (!chatbotContainer.classList.contains('hidden')) {
            chatbotInput.focus();
        }
    });

    // Close chatbot
    chatbotClose.addEventListener('click', function() {
        chatbotContainer.classList.add('hidden');
    });

    // Send message handlers
    chatbotSend.addEventListener('click', sendMessage);
    chatbotInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });

    // Enhanced send message function with better error handling
    function sendMessage() {
        const message = chatbotInput.value.trim();
        
        if (message === '') return;
        
        // Add user message
        addUserMessage(message);
        chatbotInput.value = '';
        
        // Show enhanced typing indicator
        showTypingIndicator();
        
        // Send to server with retry mechanism
        sendMessageToServer(message)
            .then(data => {
                removeTypingIndicator();
                handleServerResponse(data, message);
            })
            .catch(error => {
                console.error('Chatbot Error:', error);
                removeTypingIndicator();
                addBotMessage("🔄 Ups, saya sedang mengalami sedikit gangguan. Coba kirim pesan lagi dalam beberapa detik ya!");
                
                // Add retry button
                addRetryOption(message);
            });
    }

    // Enhanced server communication with retry
    async function sendMessageToServer(message, retryCount = 0) {
        const maxRetries = 2;
        
        try {
            const response = await fetch('/chatbot', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                },
                body: JSON.stringify({ 
                    message: message,
                    timestamp: new Date().toISOString()
                })
            });

            if (!response.ok) {
                throw new Error(`Server responded with ${response.status}: ${response.statusText}`);
            }

            return await response.json();
        } catch (error) {
            if (retryCount < maxRetries) {
                console.log(`Retrying... (${retryCount + 1}/${maxRetries})`);
                await new Promise(resolve => setTimeout(resolve, 1000)); // Wait 1 second
                return sendMessageToServer(message, retryCount + 1);
            }
            throw error;
        }
    }

    // Enhanced response handler
    function handleServerResponse(data, originalMessage) {
        if (data.type === 'text') {
            addBotMessage(data.content);
            
            // Update quick replies based on response context
            if (data.content.includes('pesanan') || data.content.includes('order')) {
                updateQuickReplies('order_tracking');
            } else if (data.content.includes('produk') || data.content.includes('kategori')) {
                updateQuickReplies('product_search');
            } else if (data.content.includes('promo') || data.content.includes('diskon')) {
                updateQuickReplies('promotion');
            }
            
        } else if (data.type === 'product_suggestion') {
            addBotMessage(data.content);
            
            if (data.products && data.products.length > 0) {
                addProductCarousel(data.products);
                
                // Add helpful follow-up after product suggestions
                setTimeout(() => {
                    addBotMessage("💡 Klik produk di atas untuk melihat detail lengkap. Butuh rekomendasi lain?");
                }, 1500);
            }
        } else if (data.type === 'order_status') {
            // Handle specific order status responses
            addBotMessage(data.content);
            addQuickAction('Lacak pesanan lain', 'Track another order');
        }
    }

    // Enhanced user message display
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

    // Enhanced bot message display with markdown-like formatting
    function addBotMessage(message) {
        const messageElement = document.createElement('div');
        messageElement.className = 'flex mb-4';
        
        // Simple markdown-like parsing
        let formattedMessage = message
            .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
            .replace(/_(.*?)_/g, '<em>$1</em>')
            .replace(/\n/g, '<br>');
            
        messageElement.innerHTML = `
            <div class="flex items-start space-x-2">
                <div class="flex-shrink-0 w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center">
                    <span class="text-white text-sm">🤖</span>
                </div>
                <div class="bg-gray-100 rounded-lg py-3 px-4 max-w-[70%] shadow-sm">
                    <div class="text-sm">${formattedMessage}</div>
                    <span class="text-xs text-gray-500 mt-1 block">${new Date().toLocaleTimeString('id-ID', {hour: '2-digit', minute: '2-digit'})}</span>
                </div>
            </div>
        `;
        chatbotMessages.appendChild(messageElement);
        scrollToBottom();
    }

    // Enhanced typing indicator with more realistic animation
    function showTypingIndicator() {
        const indicatorElement = document.createElement('div');
        indicatorElement.id = 'typing-indicator';
        indicatorElement.className = 'flex mb-4';
        indicatorElement.innerHTML = `
            <div class="flex items-start space-x-2">
                <div class="flex-shrink-0 w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center">
                    <span class="text-white text-sm">🤖</span>
                </div>
                <div class="bg-gray-100 rounded-lg py-3 px-4 flex items-center space-x-1">
                    <div class="flex space-x-1">
                        <div class="w-2 h-2 bg-gray-500 rounded-full animate-bounce"></div>
                        <div class="w-2 h-2 bg-gray-500 rounded-full animate-bounce" style="animation-delay: 0.1s"></div>
                        <div class="w-2 h-2 bg-gray-500 rounded-full animate-bounce" style="animation-delay: 0.2s"></div>
                    </div>
                    <span class="text-xs text-gray-500 ml-2">Mengetik...</span>
                </div>
            </div>
        `;
        chatbotMessages.appendChild(indicatorElement);
        scrollToBottom();
    }

    // Remove typing indicator
    function removeTypingIndicator() {
        const indicator = document.getElementById('typing-indicator');
        if (indicator) {
            indicator.remove();
        }
    }

    // Enhanced product carousel with better responsive design
    function addProductCarousel(products) {
        const carouselElement = document.createElement('div');
        carouselElement.className = 'flex mb-4';
        
        let carouselHTML = `
            <div class="w-full">
                <div class="flex overflow-x-auto space-x-3 pb-3" style="scrollbar-width: thin;">
        `;
        
        products.forEach((product, index) => {
            const formattedPrice = new Intl.NumberFormat('id-ID', {
                style: 'currency',
                currency: 'IDR',
                minimumFractionDigits: 0
            }).format(product.price);

            carouselHTML += `
                <a href="${product.url}" class="flex-shrink-0 w-44 bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-all duration-300 border border-gray-200 hover:border-blue-300" target="_blank">
                    <div class="h-36 bg-gray-50 flex items-center justify-center overflow-hidden">
                        <img src="${product.image || '/images/placeholder.png'}" 
                             alt="${escapeHTML(product.name)}" 
                             class="w-full h-full object-cover hover:scale-105 transition-transform duration-300"
                             onerror="this.src='/images/placeholder.png'"
                             loading="lazy">
                    </div>
                    <div class="p-3">
                        <h4 class="text-sm font-medium text-gray-900 line-clamp-2 mb-1">${escapeHTML(product.name)}</h4>
                        <p class="text-lg font-bold text-blue-600">${formattedPrice}</p>
                        ${product.sold_count ? `<p class="text-xs text-gray-500 mt-1">Terjual ${product.sold_count}+</p>` : ''}
                        <div class="mt-2">
                            <span class="inline-block bg-blue-100 text-blue-800 text-xs px-2 py-1 rounded-full">Lihat Detail</span>
                        </div>
                    </div>
                </a>
            `;
        });
        
        carouselHTML += `
                </div>
                <div class="text-center mt-2">
                    <span class="text-xs text-gray-500">↔ Geser untuk melihat lebih banyak</span>
                </div>
            </div>
        `;
        
        carouselElement.innerHTML = carouselHTML;
        chatbotMessages.appendChild(carouselElement);
        scrollToBottom();
    }

    // Add quick action buttons
    function addQuickAction(label, value) {
        const actionElement = document.createElement('div');
        actionElement.className = 'flex justify-center mb-4';
        actionElement.innerHTML = `
            <button class="bg-blue-500 hover:bg-blue-600 text-white text-sm px-4 py-2 rounded-lg transition-colors duration-200" 
                    onclick="document.getElementById('chatbot-input').value='${value}'; this.closest('.flex').remove();">
                ${label}
            </button>
        `;
        chatbotMessages.appendChild(actionElement);
        scrollToBottom();
    }

    // Add retry option for failed messages
    function addRetryOption(originalMessage) {
        const retryElement = document.createElement('div');
        retryElement.className = 'flex justify-center mb-4';
        retryElement.innerHTML = `
            <button class="bg-orange-500 hover:bg-orange-600 text-white text-sm px-4 py-2 rounded-lg transition-colors duration-200" 
                    onclick="this.closest('.flex').remove(); document.querySelector('#chatbot-input').value='${escapeHTML(originalMessage)}'; document.querySelector('#chatbot-send').click();">
                🔄 Coba Kirim Lagi
            </button>
        `;
        chatbotMessages.appendChild(retryElement);
        scrollToBottom();
    }

    // Enhanced scroll function with smooth behavior
    function scrollToBottom() {
        chatbotMessages.scrollTo({
            top: chatbotMessages.scrollHeight,
            behavior: 'smooth'
        });
    }

    // Enhanced HTML escaping
    function escapeHTML(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    // Initialize quick replies if they exist in DOM
    const existingQuickReplies = document.querySelectorAll('.chatbot-quick-reply');
    existingQuickReplies.forEach(reply => {
        reply.addEventListener('click', function() {
            chatbotInput.value = this.textContent;
            sendMessage();
        });
    });

    // Auto-resize input field
    chatbotInput.addEventListener('input', function() {
        this.style.height = 'auto';
        this.style.height = (this.scrollHeight) + 'px';
    });

    // Prevent form submission on Enter (handled by keypress event)
    const chatForm = chatbotInput.closest('form');
    if (chatForm) {
        chatForm.addEventListener('submit', function(e) {
            e.preventDefault();
            sendMessage();
        });
    }

    // Add keyboard shortcuts
    document.addEventListener('keydown', function(e) {
        // Alt + C to toggle chatbot
        if (e.altKey && e.key === 'c') {
            e.preventDefault();
            chatbotButton.click();
        }
        
        // Escape to close chatbot
        if (e.key === 'Escape' && !chatbotContainer.classList.contains('hidden')) {
            chatbotClose.click();
        }
    });

    // Visual feedback when chatbot is thinking
    let isProcessing = false;
    
    function setProcessingState(processing) {
        isProcessing = processing;
        chatbotSend.disabled = processing;
        chatbotInput.disabled = processing;
        
        if (processing) {
            chatbotSend.innerHTML = '⏳';
            chatbotSend.className = chatbotSend.className.replace('hover:bg-blue-600', 'opacity-50 cursor-not-allowed');
        } else {
            chatbotSend.innerHTML = '➤';
            chatbotSend.className = chatbotSend.className.replace('opacity-50 cursor-not-allowed', 'hover:bg-blue-600');
        }
    }

    // Update sendMessage to use processing state
    const originalSendMessage = sendMessage;
    sendMessage = function() {
        if (isProcessing) return;
        
        setProcessingState(true);
        originalSendMessage();
    };

    // Update response handlers to reset processing state
    const originalHandleServerResponse = handleServerResponse;
    handleServerResponse = function(data, originalMessage) {
        setProcessingState(false);
        originalHandleServerResponse(data, originalMessage);
    };

    // Reset processing state on error
    window.addEventListener('error', function() {
        setProcessingState(false);
        removeTypingIndicator();
    });
});