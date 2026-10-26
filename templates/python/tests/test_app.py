from pytest import CaptureFixture

from app.__main__ import main


def test_main(capsys: CaptureFixture[str]) -> None:
    main()
    assert capsys.readouterr().out == "Python project is ready.\n"
