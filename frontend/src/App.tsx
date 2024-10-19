import { Header, BottomNavigation } from './layouts';
import { RaffleState } from './components';

export default function App() {
  return (
    <div>
      <div className="sticky top-0 z-10 bg-white">
        <Header />
        <RaffleState />
      </div>
      <div className="min-h-screen"></div>
      <BottomNavigation />
    </div>
  );
}
