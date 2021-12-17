//
//  ViewController.swift
//  05_titmer_app
//
//  Created by Jacob Ko on 2021/12/17.
//

import UIKit
import AudioToolbox

enum TimerStatus {
	case start
	case pause
	case end
}

class ViewController: UIViewController {
	@IBOutlet weak var timerLabel: UILabel!
	@IBOutlet weak var pregressView: UIProgressView!
	@IBOutlet weak var datePicker: UIDatePicker!
	@IBOutlet weak var cancelBtn: UIButton!
	@IBOutlet weak var toggleBtn: UIButton!
	@IBOutlet weak var imageView: UIImageView!
	
	// timer에 설정된 시간을 초로 저장하는 property
	var duration = 60
	// timer 에 상태를 가지고 있는 property
	var timerStatus: TimerStatus = .end
	// disPatchSourceTimer property
	var timer: DispatchSourceTimer?
	// 현재 countDown 되고 있는 시간을 초로 저장하는 property
	var currentSeconds = 0
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.configureToggleButton()
	}
	
	// hidden value 값 설정
	func setTimerInfoViewVisable(isHidden: Bool) {
		self.timerLabel.isHidden = isHidden
		self.pregressView.isHidden = isHidden
	}
	
	// 시작버튼을 눌를때, start label 이 pause 가 되게 설정 method(버튼의 상태에따라 label 의 변경)
	func configureToggleButton() {
		self.toggleBtn.setTitle("Start", for: .normal) // 초기상태
		self.toggleBtn.setTitle("Pause", for: .selected) // 선택된 상태
	}
	
	// timer 를 설정하고, timer 가 시작되는 method
	func startTimer() {
		// timer 가 nil 일때 makeTimerSource 생성 : flags 에 빈배열 넘겨주고, queue parameter 에는 어떤 thread queue 에서 반복동작할건지 설정해주는 것(timer 가 돌때마다, UI 작업을 해줘야 함. 예를 들어 남은 시간을 표시할 수 있게 update 해줘야 하며, pregressView 도 update 해줘야 함 => .main thread 에서 반복 동작 하게끔 설정함
		// GCD 에서 main thread 는 app 전체에서 오직 한개만 존재함, 그래서 일반적인 code 는 main thread 에서 실행되는데, 작성된 code 는 cocoa에서 실행되는데, cocoa 는 매번 main thread 를 호출해서 작업을 처리하는 logic 이 있음
		// main thread 에서 중요한 점은, intefaced thread 라고 불리는데, user 가 interface 에 접근하면, event 를 main thread 에 전달 되며, 작성한 code 가 거기에 반응하게 됨. 즉, interface 와 관련된 code 는 반드시, main thread 에서 작성되어야 함을 의미 합니다(UI와 관련된 작업은 main thread 에서 이뤄져야함)
		if self.timer == nil {
			self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
			// schedule: 어떠한 주기로 timer 가 실행되는지 설정해줘야 함 deadline: .now 는 timer 가 시작되면 즉시 실행되게 함 (예로 3초뒤에 실행되야 하면 .now() + 3 해주면 됨). repating 은 몇초마다 반복할건지 설정하는것 1초마다 반복 설정
			self.timer?.schedule(deadline: .now(), repeating: 1)
			// setEventHandler: timer 와 함께 연동된 eventHandler 할당 => 클로져 함수로 timer 가 동작할때 마다, handler closure 함수가 호출이 됨( 여기선 1초에 한번씩 handler 에 구현되는 code 가 실행되게 됨)
			self.timer?.setEventHandler(handler: { [weak self] in
				// 일시적으로 self 가 strong reference 가 되게 함
				guard let self = self else { return }
				self.currentSeconds -= 1 // 초당 1씩 감소하게 함
				// 초를 시,분,초로 변환하기
				let hour = self.currentSeconds / 3600 // 초를 3600 으로 나누면 시간
				let minutes = (self.currentSeconds % 3600) / 60 // 분은 3600으로 나눈 나머지에서 60 나누기
				let seconds = (self.currentSeconds % 3600) % 60 // 초는 3600으로 나눈 나머지에 60의 나머지 값
				// String 포멧 형식으로 2자리 숫자에 : 으로 구분된 형식으로 하고, arguments 에는 hour, minutes, seconds 할당
				self.timerLabel.text = String(format: "%02d:%02d:%02d", hour, minutes, seconds)
				// debugPrint(self.currentSeconds)
				
				// 시간에 맞춰서 progressBar 도 줄어드는 logic: countDown 되고 있는 시간을 datePicker 에서 설정한 총 시간을 나눠 주면 countDown 될 때마다 progress 게이지가 줄어 들게 됨(progress 는 Float type 으로 변환 시켜야 함)
				self.pregressView.progress = Float(self.currentSeconds) / Float(self.duration)
				// debugPrint(self.pregressView.progress)
				
				// image rotation animation
				UIView.animate(withDuration: 0.5, delay: 0, animations: {
					// CGAffineTransform 은 구조체 인데, view 의 frame 을 계산하지 않고 2D 그래픽을 그릴 수 있습니다. (예를 들어 View를 이동 시키거나, 회전시키는 효과를 줄수 있습니다. rotationAngle: .pi 은 180도 회전을 의미합니다.
					self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
				})
				// 다시 360도 회전 시킴 : 위에 180 도 회전 animation 이 끝나면 동작 할 수 있게 delay 0.5 설정
				UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
					self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2)
				})
				
				// currentSeconds 가 0보다 작거나, 같다면 countDown 이 끝난것이기 때문에
				if self.currentSeconds <= 0 {
					// timer 종료 code
					self.stopTimer() // timer 종료
					// 0이 되면 알림 울리게 함: 아이폰 기본 alert 사운드 재생 시킴
					AudioServicesPlaySystemSound(1005)
				}
			})
			// hander closure 가 완료 되면 timer 가 시작되게 함
			self.timer?.resume()
		}
	}
	
	// timer 가 0보다 같거나 작을때 와 cancelBtn 을 누르면 timer 가 종료되는 method
	func stopTimer() {
		// .pause 상태 일경우에 resume method 생성되게 작성
		if self.timerStatus == .pause {
			self.timer?.resume()
		}
		self.timerStatus = .end
		self.cancelBtn.isEnabled = false
		// alpha 값 조절을 통한 animation
		UIView.animate(withDuration: 0.7, animations: {
			self.timerLabel.alpha = 0
			self.pregressView.alpha = 0
			self.datePicker.alpha = 1
			self.imageView.transform = .identity // cancel 되면 imageView 가 원상태로 되게 함
		})
		self.toggleBtn.isSelected = false
		self.timer?.cancel() // timer 종료
		self.timer = nil // timer 메모리에서 해재 시킴: 해재 안시키면 화면을 벗어나도, timer 가 계속 동작 할 수 있음
	}
	
	
	// tabCancelBtn event action
	@IBAction func tabCancelBtn(_ sender: UIButton) {
		switch self.timerStatus {
			// start, paue 상태에서 cancelBtn 누르면 .end 상태로 놓고, cancelBtn 을 비활성화로 하고, timerLabel과 pregressView 가 표시되지 않게함, datePicker 가 다시 표시되게 함, toggleBtn이 strart 되게 함
		case .start, .pause:
			self.stopTimer() // 타이머 종료
	
		default:
			break
		}
	}
	
	// tabToggleBtn event action
	@IBAction func tabToggleBtn(_ sender: UIButton) {
		// datePicker 의 countDownDuration 이 선택한 시간이 몇 초인지 알려주는 기능 (2분을 설정하면 120초 라고 알려줌)
		self.duration = Int(self.datePicker.countDownDuration)
		// debugPrint(self.duration)
		
		// end 일 경우에 start 로 바꾸고, start 이면 .pause 로 바꾸고
		switch self.timerStatus {
			// end 일경우 아직 시작 안한상태 timer label 과 progressView 가 표시되게 하고, datePicker 가 hidden 되게 함
		case .end:
			self.currentSeconds = self.duration // 현재 시간을 duration 에 대입 시킴
			self.timerStatus = .start
			// alpha 값 조절을 통한 animation
			UIView.animate(withDuration: 0.7, animations: {
				self.timerLabel.alpha = 1
				self.pregressView.alpha = 1
				self.datePicker.alpha = 0
			})
			self.toggleBtn.isSelected = true
			self.cancelBtn.isEnabled = true
			self.startTimer() // timer 시작
			
			// start 인 경우 이미 시작된 상태이니 toggleBtn 을 pause로,
		case .start:
			self.timerStatus = .pause
			self.toggleBtn.isSelected = false
			self.timer?.suspend() // timer 를 일시정지 시키기
			
			// puase 인경우 일시정지 상태니, toggleBtn 을 다시 start 되게 함
		case .pause:
			self.timerStatus = .start
			self.toggleBtn.isSelected = true
			self.timer?.resume() // 다시 timer 를 시작 시키기
		}
	}
}

