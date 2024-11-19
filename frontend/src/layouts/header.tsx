import { Search, User } from 'lucide-react';
import { ConnectButton } from '@mysten/dapp-kit';

export const Header = () => {
  return (
    <div className="relative mx-4 mb-6 flex items-center justify-between gap-6 pt-2">
      <div className="absolute inset-0 flex justify-center md:static">
        Suipstakes
      </div>
      <form className="hidden grow md:block">
        <div className="flex max-w-[560px] overflow-hidden rounded border border-secondary-border has-[:focus]:border-gray-800">
          <input
            type="text"
            placeholder="抽選イベントを検索"
            className="w-full bg-neutral-100 pl-4 pr-1 outline-none focus:border-blue-500"
          />
          <button
            type="button"
            className="bg-gray-100 p-[8px] hover:bg-gray-200"
          >
            <Search className="size-[18px] stroke-2" />
          </button>
        </div>
      </form>
      <div className="ml-auto flex shrink-0 items-center md:gap-2">
        <button
          type="button"
          className="p-2 hover:bg-secondary-hover md:hidden"
        >
          <Search className="size-[22px] stroke-2" />
        </button>
        <button
          type="button"
          className="hidden gap-1 p-2 hover:bg-secondary-hover md:flex"
        >
          <User className="size-[22px] stroke-2" />
          0x123...456
        </button>
        <div className="App">
          <header className="App-header">
            <ConnectButton />
          </header>
        </div>
        <button
          type="button"
          className="hidden rounded bg-blue-500 px-4 py-2 text-sm font-bold text-white hover:bg-blue-400 md:block"
        >
          抽選イベントを作成
        </button>
      </div>
    </div>
  );
};
