import HeaderAuth from "./header-auth";
import { ThemeSwitcher } from "./theme-switcher";

const Header = () => {
	return (
		<header className="flex justify-between p-4">
			<div />
			<div>
				<ThemeSwitcher />
				<HeaderAuth />
			</div>
		</header>
	);
};

export default Header;
