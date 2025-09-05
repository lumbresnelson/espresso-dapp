import React, { useState } from 'react';
import { useInternetIdentity } from './hooks/useInternetIdentity';
import { useGetCallerUserProfile } from './hooks/useQueries';
import LoginButton from './components/LoginButton';
import ProfileSetup from './components/ProfileSetup';
import DeploymentInterface from './components/DeploymentInterface';
import DeploymentLogs from './components/DeploymentLogs';
import DonationSection from './components/DonationSection';
import UserDashboard from './components/UserDashboard';
import DonationUsageBreakdown from './components/DonationUsageBreakdown';
import { Rocket, History, Heart, User } from 'lucide-react';

export default function App() {
  const { identity } = useInternetIdentity();
  const { data: userProfile, isLoading: profileLoading, isFetched } = useGetCallerUserProfile();
  const [activeTab, setActiveTab] = useState<'deploy' | 'logs' | 'dashboard' | 'donate'>('deploy');

  const isAuthenticated = !!identity;
  const showProfileSetup = isAuthenticated && !profileLoading && isFetched && userProfile === null;

  const tabs = [
    { id: 'deploy' as const, label: 'Deploy', icon: Rocket },
    { id: 'logs' as const, label: 'Deployment Logs', icon: History },
    ...(isAuthenticated ? [{ id: 'dashboard' as const, label: 'My Deployments', icon: User }] : []),
    { id: 'donate' as const, label: 'Support Espresso', icon: Heart },
  ];

  return (
    <div className="min-h-screen bg-gray-900 text-white">
      {/* Header */}
      <header className="bg-gray-800 border-b border-gray-700">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center space-x-3">
              <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center">
                <Rocket className="w-5 h-5 text-white" />
              </div>
              <h1 className="text-xl font-bold text-white">Espresso</h1>
              <span className="text-sm text-gray-400">Canister Deployment Platform</span>
            </div>
            <div className="flex items-center space-x-4">
              {isAuthenticated && userProfile && (
                <span className="text-sm text-gray-300">
                  Welcome, {userProfile.name}
                </span>
              )}
              <LoginButton />
            </div>
          </div>
        </div>
      </header>

      {/* Profile Setup Modal */}
      {showProfileSetup && <ProfileSetup />}

      {/* Navigation Tabs */}
      <nav className="bg-gray-800 border-b border-gray-700">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex space-x-8">
            {tabs.map((tab) => {
              const Icon = tab.icon;
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`flex items-center space-x-2 py-4 px-1 border-b-2 font-medium text-sm transition-colors ${
                    activeTab === tab.id
                      ? 'border-blue-500 text-blue-400'
                      : 'border-transparent text-gray-400 hover:text-gray-300 hover:border-gray-300'
                  }`}
                >
                  <Icon className="w-4 h-4" />
                  <span>{tab.label}</span>
                </button>
              );
            })}
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {activeTab === 'deploy' && (
          <div className="space-y-8">
            <DeploymentInterface />
            <DonationUsageBreakdown />
          </div>
        )}
        {activeTab === 'logs' && <DeploymentLogs />}
        {activeTab === 'dashboard' && isAuthenticated && <UserDashboard />}
        {activeTab === 'donate' && <DonationSection />}
      </main>

      {/* Footer */}
      <footer className="bg-gray-800 border-t border-gray-700 mt-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="text-center text-gray-400 text-sm">
            © 2025. Built with <Heart className="w-4 h-4 inline text-red-500" /> using{' '}
            <a
              href="https://caffeine.ai"
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-400 hover:text-blue-300 transition-colors"
            >
              caffeine.ai
            </a>
          </div>
        </div>
      </footer>
    </div>
  );
}
