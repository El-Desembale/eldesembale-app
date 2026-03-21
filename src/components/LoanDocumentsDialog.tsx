'use client';

import { useState } from 'react';
import { LoanInformation } from '@/lib/types';

interface Props {
  loanInfo: LoanInformation;
  onClose: () => void;
}

const TABS = [
  { key: 'ccFrontalPicture', label: 'CC Frontal' },
  { key: 'ccBackPicture', label: 'CC Trasera' },
  { key: 'selfiePicture', label: 'Selfie' },
  { key: 'empInvoiceFile', label: 'Comprobante' },
] as const;

export function LoanDocumentsDialog({ loanInfo, onClose }: Props) {
  const [activeTab, setActiveTab] = useState<(typeof TABS)[number]['key']>('ccFrontalPicture');

  const currentUrl = loanInfo[activeTab];

  const isPdf = currentUrl?.toLowerCase().includes('.pdf') ||
    currentUrl?.toLowerCase().includes('application/pdf');

  return (
    <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-50 p-4">
      <div className="bg-[#0a1a0a] border border-[#2FFF00]/30 rounded-2xl w-full max-w-2xl max-h-[90vh] flex flex-col">
        {/* Header */}
        <div className="flex justify-between items-center p-4 border-b border-[#2FFF00]/20">
          <h2 className="text-white font-bold text-lg">Documentos</h2>
          <button onClick={onClose} className="text-gray-400 hover:text-white text-2xl leading-none">
            ×
          </button>
        </div>

        {/* Tabs */}
        <div className="flex gap-2 p-4 border-b border-[#2FFF00]/20 overflow-x-auto">
          {TABS.map(tab => (
            <button
              key={tab.key}
              onClick={() => setActiveTab(tab.key)}
              className={`px-3 py-1.5 rounded-full text-sm font-medium whitespace-nowrap transition-all ${
                activeTab === tab.key
                  ? 'bg-[#2FFF00] text-black'
                  : 'bg-[#2FFF00]/10 text-[#2FFF00] hover:bg-[#2FFF00]/20'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>

        {/* Content */}
        <div className="flex-1 overflow-auto p-4 flex items-center justify-center min-h-[300px]">
          {currentUrl ? (
            isPdf ? (
              <iframe
                src={currentUrl}
                className="w-full h-full min-h-[400px] rounded-lg"
                title={activeTab}
              />
            ) : (
              <img
                src={currentUrl}
                alt={activeTab}
                className="max-w-full max-h-[500px] object-contain rounded-lg"
              />
            )
          ) : (
            <p className="text-gray-500">No hay documento disponible</p>
          )}
        </div>
      </div>
    </div>
  );
}
