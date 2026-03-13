"""AI Advisor router – Comprehensive farming knowledge base."""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from typing import List, Optional

router = APIRouter(prefix="/ai", tags=["AI Advisor"])


class ChatMessage(BaseModel):
    role: str  # 'user' or 'assistant'
    content: str = Field(..., min_length=1, max_length=2000)


class ChatRequest(BaseModel):
    messages: List[ChatMessage] = Field(..., min_length=1, max_length=50)
    context: Optional[dict] = None


class ChatResponse(BaseModel):
    content: str
    suggestions: List[str] = []


# ── Knowledge Base ───────────────────────────────────────────────────────────

KNOWLEDGE_BASE = {
    "price": {
        "keywords": ["price", "rate", "cost", "market", "mandi"],
        "responses": [
            "Current market rates for major grains in Tamil Nadu:\n"
            "• Rice (Sona Masoori): ₹32-38/kg\n"
            "• Wheat: ₹24-28/kg\n"
            "• Ragi (Finger Millet): ₹28-35/kg\n"
            "• Bajra (Pearl Millet): ₹22-26/kg\n"
            "• Maize: ₹18-22/kg\n\n"
            "💡 Tip: Compare prices across multiple mandis before selling. "
            "Check the Market Prices section for real-time updates."
        ],
        "suggestions": ["Show price trends", "Best time to sell", "Market nearby", "Compare mandis"],
    },
    "yield": {
        "keywords": ["yield", "grow", "plant", "cultivation", "harvest"],
        "responses": [
            "🌾 **Crop Yield Optimization Tips:**\n\n"
            "1. **Soil Testing**: Get your soil tested every season. NPK balance is critical.\n"
            "2. **Seed Selection**: Use certified seeds from authorized dealers.\n"
            "3. **Irrigation**: \n"
            "   - Rice: Maintain 2-5cm standing water during tillering\n"
            "   - Wheat: Critical irrigation at CRI, flowering, and grain filling stages\n"
            "   - Millets: Drought-resistant but respond well to 2-3 irrigations\n"
            "4. **Fertilizer Schedule**: Apply basal dose at sowing, top dress at 21 and 42 DAS.\n"
            "5. **Weed Management**: Keep fields weed-free for first 45 days.\n\n"
            "📊 Expected yields (per hectare):\n"
            "• Rice: 4-6 tonnes | Wheat: 3-5 tonnes | Millet: 2-3 tonnes"
        ],
        "suggestions": ["Fertilizer guide", "Soil testing labs", "Pest control", "Irrigation schedule"],
    },
    "millet": {
        "keywords": ["millet", "ragi", "bajra", "jowar", "kuthiraivali", "thinai", "samai"],
        "responses": [
            "🌻 **Millet Varieties & Benefits:**\n\n"
            "**Finger Millet (Ragi)**: Rich in calcium (344mg/100g), iron. Best for diabetics.\n"
            "**Pearl Millet (Bajra)**: High protein (11.6g), iron-rich. Grows in arid zones.\n"
            "**Foxtail Millet (Thinai)**: Low glycemic index. Good for weight management.\n"
            "**Barnyard Millet (Kuthiraivali)**: Highest fiber content among millets.\n"
            "**Little Millet (Samai)**: Rich in B-vitamins, easy to cook.\n\n"
            "🌿 **Growing Tips:**\n"
            "- Millets need minimal water (200-300mm rainfall)\n"
            "- Best sowing: June-July (Kharif) or January (Rabi for some)\n"
            "- Harvest: 90-120 days after sowing\n"
            "- 2023 was declared International Year of Millets by UN!"
        ],
        "suggestions": ["Millet recipes", "Selling millets", "Millet farming guide", "Government schemes"],
    },
    "order": {
        "keywords": ["order", "buy", "purchase", "track", "delivery"],
        "responses": [
            "📦 **Order Management:**\n\n"
            "• Track your orders in the **Orders** tab\n"
            "• Order statuses: Pending → Confirmed → Processing → Shipped → Delivered\n"
            "• You can cancel an order before it's shipped\n"
            "• Payment is processed through secure Razorpay gateway\n\n"
            "**For Farmers:**\n"
            "• Accept orders promptly to build buyer trust\n"
            "• Update order status regularly\n"
            "• Maintain quality standards for repeat business\n\n"
            "**For Buyers:**\n"
            "• Check crop details and farmer verification before ordering\n"
            "• Provide accurate delivery address\n"
            "• Rate your experience after delivery"
        ],
        "suggestions": ["Track latest order", "Contact support", "Return policy"],
    },
    "weather": {
        "keywords": ["weather", "rain", "monsoon", "climate", "season", "drought", "flood"],
        "responses": [
            "🌦️ **Weather & Farming Advisory:**\n\n"
            "**Kharif Season (June-October):**\n"
            "• Best for: Rice, Maize, Sorghum, Pearl Millet, Cotton\n"
            "• Monitor southwest monsoon forecasts regularly\n"
            "• Prepare drainage in waterlogged areas\n\n"
            "**Rabi Season (October-March):**\n"
            "• Best for: Wheat, Barley, Mustard, Gram\n"
            "• Requires residual soil moisture or irrigation\n\n"
            "**Summer (March-June):**\n"
            "• Best for: Sunflower, Groundnut, Vegetables\n"
            "• Ensure adequate irrigation scheduling\n\n"
            "💡 Tip: Always check the IMD (India Meteorological Department) "
            "forecast before planning field operations."
        ],
        "suggestions": ["IMD forecast", "Crop calendar", "Drought management", "Flood protection"],
    },
    "pest": {
        "keywords": ["pest", "disease", "insect", "fungus", "blight", "wilt", "spray"],
        "responses": [
            "🐛 **Common Crop Pests & Management:**\n\n"
            "**Rice:**\n"
            "• Stem Borer → Use Trichogramma biocontrol agents\n"
            "• BPH (Brown Plant Hopper) → Avoid excess nitrogen, use neem oil\n"
            "• Blast → Spray Tricyclazole at boot leaf stage\n\n"
            "**Wheat:**\n"
            "• Rust → Use resistant varieties (HD-2967, DBW-187)\n"
            "• Aphids → Spray Dimethoate 30EC\n\n"
            "**Millets:**\n"
            "• Shoot fly → Early sowing, use Carbofuran granules\n"
            "• Smut → Seed treatment with Carboxin\n\n"
            "🌿 **Integrated Pest Management (IPM):**\n"
            "1. Use pheromone traps for monitoring\n"
            "2. Introduce natural predators (ladybugs, lacewings)\n"
            "3. Crop rotation to break pest cycles\n"
            "4. Chemical sprays only as last resort"
        ],
        "suggestions": ["Organic pest control", "Spray schedule", "Nearby agri shops", "Government subsidy"],
    },
    "soil": {
        "keywords": ["soil", "fertilizer", "nitrogen", "phosphorus", "potassium", "organic", "compost"],
        "responses": [
            "🌍 **Soil Health Management:**\n\n"
            "**Soil Testing:**\n"
            "• Test every season at your nearest KVK or soil testing lab\n"
            "• Cost: ₹40-100 per sample (subsidized by government)\n\n"
            "**NPK Recommendations (per hectare):**\n"
            "• Rice: 120:60:40 kg NPK\n"
            "• Wheat: 120:60:40 kg NPK\n"
            "• Millets: 40:20:20 kg NPK (millets need less!)\n\n"
            "**Organic Options:**\n"
            "• Vermicompost: 2-3 tonnes/hectare\n"
            "• Jeevamrit: Rich in beneficial microbes\n"
            "• Green manure: Grow Dhaincha or Sunhemp before main crop\n\n"
            "💰 **Government Subsidy**: Soil Health Cards provide free recommendations. "
            "Apply through your local agriculture department."
        ],
        "suggestions": ["Soil testing labs", "Organic farming", "Fertilizer calculator", "SHC scheme"],
    },
    "scheme": {
        "keywords": ["scheme", "subsidy", "government", "pm", "kisan", "insurance", "loan"],
        "responses": [
            "🏛️ **Government Schemes for Farmers:**\n\n"
            "**PM-KISAN**: ₹6,000/year in 3 installments for landholding farmers\n"
            "**PMFBY (Crop Insurance)**: Premium as low as 1.5-2% of sum insured\n"
            "**KCC (Kisan Credit Card)**: Loans at 4% interest rate\n"
            "**Soil Health Card**: Free soil testing and recommendations\n"
            "**PM-KUSUM**: Solar pump subsidy up to 60%\n"
            "**e-NAM**: Online marketplace for agricultural commodities\n\n"
            "📱 **How to Apply:**\n"
            "1. Visit your nearest Common Service Centre (CSC)\n"
            "2. Use the PM-KISAN portal: pmkisan.gov.in\n"
            "3. Contact your Block Agricultural Officer\n\n"
            "💡 Tip: Keep your Aadhaar linked to your bank account for direct benefits."
        ],
        "suggestions": ["PM-KISAN status", "Crop insurance", "KCC application", "Subsidy calculator"],
    },
}


def _find_response(query: str) -> tuple:
    """Find the best matching response for a query."""
    query_lower = query.lower()

    for topic, data in KNOWLEDGE_BASE.items():
        for keyword in data["keywords"]:
            if keyword in query_lower:
                response = data["responses"][0] if isinstance(data["responses"], list) else data["responses"]
                return response, data["suggestions"]

    return None, None


@router.post("/chat", response_model=ChatResponse)
def chat_with_advisor(body: ChatRequest):
    """
    AI Advisor with comprehensive farming knowledge base.
    Covers prices, yields, millets, orders, weather, pests, soil, and government schemes.
    """
    if not body.messages:
        raise HTTPException(status_code=400, detail="No messages provided")

    last_user_message = next(
        (m.content for m in reversed(body.messages) if m.role == "user"), ""
    )

    if not last_user_message.strip():
        raise HTTPException(status_code=400, detail="Empty message")

    # Find matching knowledge base entry
    content, suggestions = _find_response(last_user_message)

    if content:
        return ChatResponse(content=content, suggestions=suggestions)

    # Default fallback response
    return ChatResponse(
        content=(
            "👋 I'm the **Farmaa AI Advisor**! I can help you with:\n\n"
            "🌾 **Market Prices** – Current rates for grains across mandis\n"
            "🌱 **Crop Advice** – Yield optimization, pest control, soil health\n"
            "🌻 **Millets** – Varieties, benefits, and growing tips\n"
            "📦 **Orders** – Track and manage your marketplace orders\n"
            "🌦️ **Weather** – Seasonal farming guidance\n"
            "🏛️ **Government Schemes** – PM-KISAN, PMFBY, KCC, and more\n\n"
            "Try asking me something specific! For example:\n"
            "• \"What's the current price of rice?\"\n"
            "• \"How do I control pests in wheat?\"\n"
            "• \"What government schemes can I apply for?\""
        ),
        suggestions=[
            "Market prices",
            "Crop advice",
            "Millet guide",
            "Government schemes",
            "Pest control",
            "Soil health",
        ],
    )
