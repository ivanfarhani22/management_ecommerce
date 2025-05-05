document.addEventListener('DOMContentLoaded', function() {
    // Get elements
    const chatbotButton = document.getElementById('chatbot-button');
    const chatbotContainer = document.getElementById('chatbot-container');
    const chatbotMessages = document.getElementById('chatbot-messages');
    const chatbotInput = document.getElementById('chatbot-input');
    const chatbotSend = document.getElementById('chatbot-send');
    const chatbotClose = document.getElementById('chatbot-close');

    // Toggle chatbot visibility when button is clicked
    chatbotButton.addEventListener('click', function() {
        chatbotContainer.classList.toggle('hidden');
        
        // If opening the chatbot and no messages yet, show welcome message
        if (!chatbotContainer.classList.contains('hidden') && chatbotMessages.children.length === 0) {
            addBotMessage("Hello! 👋 I'm your virtual assistant for Digital Ecommerce. How can I help you today? You can ask me about our watches, electronics, shipping, or payment options.");
        }
        
        // Focus on input when opening
        if (!chatbotContainer.classList.contains('hidden')) {
            chatbotInput.focus();
        }
    });

    // Close chatbot when close button is clicked
    chatbotClose.addEventListener('click', function() {
        chatbotContainer.classList.add('hidden');
    });

    // Send message when send button is clicked
    chatbotSend.addEventListener('click', sendMessage);

    // Send message when Enter key is pressed in input field
    chatbotInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            sendMessage();
        }
    });

    // Function to send message
    function sendMessage() {
        const message = chatbotInput.value.trim();
        
        // Don't send empty messages
        if (message === '') return;
        
        // Add user message to chat
        addUserMessage(message);
        
        // Clear input field
        chatbotInput.value = '';
        
        // Show typing indicator
        showTypingIndicator();
        
        // Send message to server - FIXED URL HERE
        fetch('/chatbot', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
            },
            body: JSON.stringify({ message: message })
        })
        .then(response => {
            // Check if response is OK
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.json();
        })
        .then(data => {
            // Remove typing indicator
            removeTypingIndicator();
            
            // Process the response based on type
            if (data.type === 'text') {
                addBotMessage(data.content);
            } else if (data.type === 'product_suggestion') {
                addBotMessage(data.content);
                
                if (data.products && data.products.length > 0) {
                    addProductCarousel(data.products);
                }
            }
        })
        .catch(error => {
            console.error('Error:', error);
            removeTypingIndicator();
            addBotMessage("I'm sorry, I'm having trouble connecting to the server. Please try again later.");
        });
    }

    // Function to add user message to chat
    function addUserMessage(message) {
        const messageElement = document.createElement('div');
        messageElement.className = 'flex justify-end mb-4';
        messageElement.innerHTML = `
            <div class="bg-blue-500 text-white rounded-lg py-2 px-4 max-w-[70%] shadow">
                ${escapeHTML(message)}
            </div>
        `;
        chatbotMessages.appendChild(messageElement);
        scrollToBottom();
    }

    // Function to add bot message to chat
    function addBotMessage(message) {
        const messageElement = document.createElement('div');
        messageElement.className = 'flex mb-4';
        messageElement.innerHTML = `
            <div class="bg-gray-200 rounded-lg py-2 px-4 max-w-[70%] shadow">
                ${message}
            </div>
        `;
        chatbotMessages.appendChild(messageElement);
        scrollToBottom();
    }

    // Function to show typing indicator
    function showTypingIndicator() {
        const indicatorElement = document.createElement('div');
        indicatorElement.id = 'typing-indicator';
        indicatorElement.className = 'flex mb-4';
        indicatorElement.innerHTML = `
            <div class="bg-gray-200 rounded-lg py-2 px-4 flex space-x-1">
                <div class="w-2 h-2 bg-gray-500 rounded-full animate-bounce"></div>
                <div class="w-2 h-2 bg-gray-500 rounded-full animate-bounce" style="animation-delay: 0.1s"></div>
                <div class="w-2 h-2 bg-gray-500 rounded-full animate-bounce" style="animation-delay: 0.2s"></div>
            </div>
        `;
        chatbotMessages.appendChild(indicatorElement);
        scrollToBottom();
    }

    // Function to remove typing indicator
    function removeTypingIndicator() {
        const indicator = document.getElementById('typing-indicator');
        if (indicator) {
            indicator.remove();
        }
    }

    // Function to add product carousel
    function addProductCarousel(products) {
        const carouselElement = document.createElement('div');
        carouselElement.className = 'flex mb-4';
        
        let carouselHTML = `
            <div class="w-full overflow-x-auto">
                <div class="flex space-x-4 pb-2">
        `;
        
        products.forEach(product => {
            carouselHTML += `
                <a href="${product.url}" class="flex-shrink-0 w-40 bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition duration-300">
                    <div class="h-32 bg-gray-100 flex items-center justify-center">
                        <img src="${product.image || '/images/placeholder.png'}" alt="${escapeHTML(product.name)}" class="max-h-full max-w-full object-contain">
                    </div>
                    <div class="p-3">
                        <p class="text-sm font-medium text-gray-900 truncate">${escapeHTML(product.name)}</p>
                        <p class="text-sm font-bold text-blue-600">$${parseFloat(product.price).toFixed(2)}</p>
                    </div>
                </a>
            `;
        });
        
        carouselHTML += `
                </div>
            </div>
        `;
        
        carouselElement.innerHTML = carouselHTML;
        chatbotMessages.appendChild(carouselElement);
        scrollToBottom();
    }

    // Function to scroll chat to bottom
    function scrollToBottom() {
        chatbotMessages.scrollTop = chatbotMessages.scrollHeight;
    }

    // Function to escape HTML to prevent XSS
    function escapeHTML(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    // Quick replies
    const quickReplies = document.querySelectorAll('.chatbot-quick-reply');
    quickReplies.forEach(reply => {
        reply.addEventListener('click', function() {
            chatbotInput.value = this.textContent;
            sendMessage();
        });
    });
});