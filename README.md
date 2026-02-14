NeuralMeet
==========

NeuralMeet is a Software as a Service (SaaS) video calling platform powered by AI.
The core feature is that users can have real-time video calls with AI agents trained
for specific roles, such as a language tutor, an interview coach, or a custom agent
with a unique personality.

After a call, the platform automatically processes the meeting to provide a structured
summary, a fully searchable transcript, and a complete call recording. It also includes
a chat interface that understands the context of the meeting, allowing users to ask
specific questions about the conversation.

Key Features
------------
Advanced Video and Audio
- High-quality video calls with Stream Video SDK
- Real-time audio processing with OpenAI Realtime API
- Live transcription and recording capabilities
- Multi-participant support with advanced controls

AI-Powered Intelligence
- Custom AI agents for meetings
- Real-time transcription
- Intelligent summaries with notes
- Background processing with Inngest

Rich Communication
- Integrated chat during video calls
- File sharing and screen sharing
- Emoji reactions and interactive elements
- Real-time collaboration tools

Enterprise-Grade Security
- Multi-factor authentication with Better Auth
- Social login (Google, GitHub)
- WebAuthn biometric authentication
- Secure session management

Meeting Management
- Meeting scheduling and organization
- Historical meeting records
- AI-generated insights and analytics
- Export capabilities for summaries

Tech Stack
----------
Frontend
- Next.js 15.3.2 (App Router)
- TypeScript
- Tailwind CSS
- Shadcn/UI
- React Hook Form

Backend and APIs
- tRPC
- Better Auth
- Drizzle ORM
- PostgreSQL (Neon serverless)

AI and Real-time Services
- OpenAI API
- OpenAI Realtime API
- Stream Video SDK
- Stream Chat SDK
- Inngest

Development and Deployment
- ESLint
- TypeScript
- Drizzle Kit
- Vercel

Getting Started
---------------
Prerequisites
- Node.js 18+
- PostgreSQL database
- OpenAI API key

Installation
1) Clone the repository
2) Install dependencies
	npm install
3) Set up environment variables
	cp .env.example .env.local

Fill in your environment variables:

# Database
DATABASE_URL="your-postgresql-url"

# Authentication
NEXT_PUBLIC_APP_URL="http://localhost:3000"
BETTER_AUTH_SECRET="your-secret-key"

# OAuth Providers
GITHUB_CLIENT_ID="your-github-client-id"
GITHUB_CLIENT_SECRET="your-github-client-secret"
GOOGLE_CLIENT_ID="your-google-client-id"
GOOGLE_CLIENT_SECRET="your-google-client-secret"

# Stream
NEXT_PUBLIC_STREAM_VIDEO_API_KEY="your-stream-video-key"
STREAM_VIDEO_SECRET_KEY="your-stream-video-secret"
NEXT_PUBLIC_STREAM_CHAT_API_KEY="your-stream-chat-key"
STREAM_CHAT_SECRET_KEY="your-stream-chat-secret"

# OpenAI
OPENAI_API_KEY="your-openai-api-key"

# Inngest
INNGEST_EVENT_KEY="your-inngest-key"

Set up the database
	npm run db:push

Start the development server
	npm run dev

Open http://localhost:3000 to see the application.

Project Structure
-----------------
```
src/
├── app/                    # Next.js App Router
├── components/
│   └── ui/                  # Shadcn/UI components
├── modules/
│   ├── auth/                # Authentication logic
│   ├── meetings/            # Meeting management
│   └── agents/              # AI agent functionality
├── lib/                     # Utility libraries
│   ├── auth.ts              # Better Auth configuration
│   ├── stream-video.ts      # Stream Video setup
│   ├── stream-chat.ts       # Stream Chat setup
│   └── trpc.ts              # tRPC configuration
├── db/
│   └── schema.ts            # Database schema
├── inngest/                 # Background job functions
└── trpc/                    # API routes and procedures
```

Available Scripts
-----------------
npm run dev        # Start development server
npm run build      # Build for production
npm run start      # Start production server
npm run lint       # Run ESLint
npm run db:push    # Push database schema
npm run db:studio  # Open Drizzle Studio

Contributing
------------
See CONTRIBUTING.md for details.



Support
-------
- GitHub Issues

Contact
-------
LinkedIn: https://www.linkedin.com/in/snehanshu-banerjee-513b5126b/
