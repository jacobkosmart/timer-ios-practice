# π° TimerApp-iOS-practice

<img width="350" alt="αα³αα³αα΅α«αα£αΊ" src="https://user-images.githubusercontent.com/28912774/146492923-8c27ce42-ef18-4ce1-a8d8-433be420d3fc.gif">

## π κΈ°λ₯ μμΈ

- DatePicker λ₯Ό ν΅ν΄ νμ΄λ¨Έ μκ°μ μ€μ ν  μ μμ΅λλ€

- μμ λ²νΌμ λλ₯΄λ©΄ νμ΄λ¨Έκ° μμλκ³  μΌμ μ μ§λ₯Ό λλ₯΄λ©΄ νμ΄λ¨Έκ° μΌμμ μ§ λ©λλ€

- μ·¨μ λ²νΌμ λλ₯΄λ©΄ νμ΄λ¨Έκ° μ’λ£λ©λλ€

- μΉ΄μ΄νΈ λ€μ΄μ΄ μλ£λλ©΄ μλμ΄ μΈλ¦½λλ€

## π Check Point !

<img width="350" alt="αα³αα³αα΅α«αα£αΊ" src="https://user-images.githubusercontent.com/28912774/146492741-fb26ade2-2b78-43b4-b3f3-da750b1068e0.png">

### π· DispatchSourceTimer

```swift
// in ViewController.swift

// timer λ₯Ό μ€μ νκ³ , timer κ° μμλλ method
func startTimer() {
	// timer κ° nil μΌλ makeTimerSource μμ± : flags μ λΉλ°°μ΄ λκ²¨μ£Όκ³ , queue parameter μλ μ΄λ€ thread queue μμ λ°λ³΅λμν κ±΄μ§ μ€μ ν΄μ£Όλ κ²(timer κ° λλλ§λ€, UI μμμ ν΄μ€μΌ ν¨. μλ₯Ό λ€μ΄ λ¨μ μκ°μ νμν  μ μκ² update ν΄μ€μΌ νλ©°, pregressView λ update ν΄μ€μΌ ν¨ => .main thread μμ λ°λ³΅ λμ νκ²λ μ€μ ν¨
	// GCD μμ main thread λ app μ μ²΄μμ μ€μ§ νκ°λ§ μ‘΄μ¬ν¨, κ·Έλμ μΌλ°μ μΈ code λ main thread μμ μ€νλλλ°, μμ±λ code λ cocoaμμ μ€νλλλ°, cocoa λ λ§€λ² main thread λ₯Ό νΈμΆν΄μ μμμ μ²λ¦¬νλ logic μ΄ μμ
	// main thread μμ μ€μν μ μ, intefaced thread λΌκ³  λΆλ¦¬λλ°, user κ° interface μ μ κ·Όνλ©΄, event λ₯Ό main thread μ μ λ¬ λλ©°, μμ±ν code κ° κ±°κΈ°μ λ°μνκ² λ¨. μ¦, interface μ κ΄λ ¨λ code λ λ°λμ, main thread μμ μμ±λμ΄μΌ ν¨μ μλ―Έ ν©λλ€(UIμ κ΄λ ¨λ μμμ main thread μμ μ΄λ€μ ΈμΌν¨)
	if self.timer == nil {
		self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
		// schedule: μ΄λ ν μ£ΌκΈ°λ‘ timer κ° μ€νλλμ§ μ€μ ν΄μ€μΌ ν¨ deadline: .now λ timer κ° μμλλ©΄ μ¦μ μ€νλκ² ν¨ (μλ‘ 3μ΄λ€μ μ€νλμΌ νλ©΄ .now() + 3 ν΄μ£Όλ©΄ λ¨). repating μ λͺμ΄λ§λ€ λ°λ³΅ν κ±΄μ§ μ€μ νλκ² 1μ΄λ§λ€ λ°λ³΅ μ€μ 
		self.timer?.schedule(deadline: .now(), repeating: 1)
		// setEventHandler: timer μ ν¨κ» μ°λλ eventHandler ν λΉ => ν΄λ‘μ Έ ν¨μλ‘ timer κ° λμν λ λ§λ€, handler closure ν¨μκ° νΈμΆμ΄ λ¨( μ¬κΈ°μ  1μ΄μ νλ²μ© handler μ κ΅¬νλλ code κ° μ€νλκ² λ¨)
		self.timer?.setEventHandler(handler: { [weak self] in
			// μΌμμ μΌλ‘ self κ° strong reference κ° λκ² ν¨
			guard let self = self else { return }
			self.currentSeconds -= 1 // μ΄λΉ 1μ© κ°μνκ² ν¨
			// μ΄λ₯Ό μ,λΆ,μ΄λ‘ λ³ννκΈ°
			let hour = self.currentSeconds / 3600 // μ΄λ₯Ό 3600 μΌλ‘ λλλ©΄ μκ°
			let minutes = (self.currentSeconds % 3600) / 60 // λΆμ 3600μΌλ‘ λλ λλ¨Έμ§μμ 60 λλκΈ°
			let seconds = (self.currentSeconds % 3600) % 60 // μ΄λ 3600μΌλ‘ λλ λλ¨Έμ§μ 60μ λλ¨Έμ§ κ°
			// String ν¬λ©§ νμμΌλ‘ 2μλ¦¬ μ«μμ : μΌλ‘ κ΅¬λΆλ νμμΌλ‘ νκ³ , arguments μλ hour, minutes, seconds ν λΉ
			self.timerLabel.text = String(format: "%02d:%02d:%02d", hour, minutes, seconds)
			// debugPrint(self.currentSeconds)

			// μκ°μ λ§μΆ°μ progressBar λ μ€μ΄λλ logic: countDown λκ³  μλ μκ°μ datePicker μμ μ€μ ν μ΄ μκ°μ λλ  μ£Όλ©΄ countDown λ  λλ§λ€ progress κ²μ΄μ§κ° μ€μ΄ λ€κ² λ¨(progress λ Float type μΌλ‘ λ³ν μμΌμΌ ν¨)
			self.pregressView.progress = Float(self.currentSeconds) / Float(self.duration)
			debugPrint(self.pregressView.progress)

			// currentSeconds κ° 0λ³΄λ€ μκ±°λ, κ°λ€λ©΄ countDown μ΄ λλκ²μ΄κΈ° λλ¬Έμ
			if self.currentSeconds <= 0 {
				// timer μ’λ£ code
				self.stopTimer() // timer μ’λ£
			}
		})
		// hander closure κ° μλ£ λλ©΄ timer κ° μμλκ² ν¨
		self.timer?.resume()
	}
}

// timer κ° 0λ³΄λ€ κ°κ±°λ μμλ μ cancelBtn μ λλ₯΄λ©΄ timer κ° μ’λ£λλ method
func stopTimer() {
	// .pause μν μΌκ²½μ°μ resume method μμ±λκ² μμ±
	if self.timerStatus == .pause {
		self.timer?.resume()
	}
	self.timerStatus = .end
	self.cancelBtn.isEnabled = false
	self.setTimerInfoViewVisable(isHidden: true)
	self.datePicker.isHidden = false
	self.toggleBtn.isSelected = false
	self.timer?.cancel() // timer μ’λ£
	self.timer = nil // timer λ©λͺ¨λ¦¬μμ ν΄μ¬ μν΄: ν΄μ¬ μμν€λ©΄ νλ©΄μ λ²μ΄λλ, timer κ° κ³μ λμ ν  μ μμ
}
```

### π· Aram μλ¦¬ λκ² νκΈ°(timer κ° μ’λ£μ)

> iPhone AudioServices - https://iphonedev.wiki/index.php/AudioServices

![image](https://user-images.githubusercontent.com/28912774/146487907-97f453d4-f790-4761-bd58-41c84814d85b.png)

```swift
import AudioToolbox

if self.currentSeconds <= 0 {
			// timer μ’λ£ code
			self.stopTimer() // timer μ’λ£
			// 0μ΄ λλ©΄ μλ¦Ό μΈλ¦¬κ² ν¨: μμ΄ν° κΈ°λ³Έ alert μ¬μ΄λ μ¬μ μν΄
			AudioServicesPlaySystemSound(1005)
		}
	})
	// hander closure κ° μλ£ λλ©΄ timer κ° μμλκ² ν¨
	self.timer?.resume()
}

```

### π· UIView Animation

#### νλ©΄μ transition ν¨κ³Ό μ μ©νκΈ° (alpha κ° μ‘°μ )

- Viewμ μ¬λΆλ₯Ό isHidden κ°μ΄ μλ, alpha κ°μΌλ‘ μ€μ ν΄μ View κ° μ¬λΌμ§κ³  νμλκ² λ§λ­λλ€. alpha κ°μ opacity κ°μ μ‘°μ νλ μΈμ μλλ€. μ΅μ 0 ~ 1κΉμ§ μ€μ νλλ° 0 μ κ°κΉμΈμλ‘ view κ° ν¬λͺν΄ μ§λλ€.

```swift

func stopTimer() {
	// .pause μν μΌκ²½μ°μ resume method μμ±λκ² μμ±
	if self.timerStatus == .pause {
		self.timer?.resume()
	}
	self.timerStatus = .end
	self.cancelBtn.isEnabled = false
	// alpha κ° μ‘°μ μ ν΅ν animation
	UIView.animate(withDuration: 0.5, animations: {
		self.timerLabel.alpha = 0
		self.pregressView.alpha = 0
		self.datePicker.alpha = 1
	})

@IBAction func tabCancelBtn(_ sender: UIButton) {
	switch self.timerStatus {
		// start, paue μνμμ cancelBtn λλ₯΄λ©΄ .end μνλ‘ λκ³ , cancelBtn μ λΉνμ±νλ‘ νκ³ , timerLabelκ³Ό pregressView κ° νμλμ§ μκ²ν¨, datePicker κ° λ€μ νμλκ² ν¨, toggleBtnμ΄ strart λκ² ν¨
	case .start, .pause:
		switch self.timerStatus {
			// end μΌκ²½μ° μμ§ μμ μνμν timer label κ³Ό progressView κ° νμλκ² νκ³ , datePicker κ° hidden λκ² ν¨
	case .end:
		self.currentSeconds = self.duration // νμ¬ μκ°μ duration μ λμ μν΄
		self.timerStatus = .start
		// alpha κ° μ‘°μ μ ν΅ν animation
		UIView.animate(withDuration: 0.5, animations: {
			self.timerLabel.alpha = 1
			self.pregressView.alpha = 1
			self.datePicker.alpha = 0
		})
```

![Kapture 2021-12-17 at 14 01 52](https://user-images.githubusercontent.com/28912774/146491720-a7d35e0f-7796-41c8-881a-29687cce3557.gif)

#### κ³ μ λμ΄ μλ image μ νμ  ν¨κ³Ό animation

```swift
	// image rotation animation
	UIView.animate(withDuration: 0.5, delay: 0, animations: {
		// CGAffineTransform μ κ΅¬μ‘°μ²΄ μΈλ°, view μ frame μ κ³μ°νμ§ μκ³  2D κ·Έλν½μ κ·Έλ¦΄ μ μμ΅λλ€. (μλ₯Ό λ€μ΄ Viewλ₯Ό μ΄λ μν€κ±°λ, νμ μν€λ ν¨κ³Όλ₯Ό μ€μ μμ΅λλ€. rotationAngle: .pi μ 180λ νμ μ μλ―Έν©λλ€.
		self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
	})
	// λ€μ 360λ νμ  μν΄ : μμ 180 λ νμ  animation μ΄ λλλ©΄ λμ ν  μ μκ² delay 0.5 μ€μ 
	UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
		self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2)
	})

	self.imageView.transform = .identity // cancel λλ©΄ imageView κ° μμνλ‘ λκ² ν¨
```

![Kapture 2021-12-17 at 14 03 38](https://user-images.githubusercontent.com/28912774/146491833-56ba41f5-5cdc-4fa5-9652-9d604fe4dbb5.gif)

> Describing check point in details in Jacob's DevLog - https://jacobko.info/ios/ios-06/

## β Error Check Point

### πΆ Pause μνμμ CancelBtn λλ₯΄λ©΄ Error λ°μ

![image](https://user-images.githubusercontent.com/28912774/146478331-414c7bb4-7243-49e2-8cd0-979e8f69e852.png)

- Timer λ₯Ό suspend λ₯Ό μ¬μ©ν΄μ μΌμμ μ§ νκ² λλ©΄, μμ§ μνν΄μΌ λ  μμμ΄ μμμ μλ―ΈνκΈ° λλ¬Έμ, suspend λ timer μ `nil` μ λμνκ² λλ©΄ `runTime error` λ°μ λ¨

- μΌμμ μ§ λ μνμμ timer λ₯Ό μ€μ§νκ³ , nil μ λμνλ €λ©΄ κ·Έμ μ resume method λ₯Ό μ€ν μμΌμΌ ν¨

#### Solving Problem

```swift
// in ViewController.swift

	// timer κ° 0λ³΄λ€ κ°κ±°λ μμλ μ cancelBtn μ λλ₯΄λ©΄ timer κ° μ’λ£λλ method
func stopTimer() {
	// .pause μν μΌκ²½μ°μ resume method μμ±λκ² μμ±
	if self.timerStatus == .pause {
		self.timer?.resume()
	}
	self.timerStatus = .end
	self.cancelBtn.isEnabled = false
	self.setTimerInfoViewVisable(isHidden: true)
	self.datePicker.isHidden = false
	self.toggleBtn.isSelected = false
	self.timer?.cancel() // timer μ’λ£
	self.timer = nil // timer λ©λͺ¨λ¦¬μμ ν΄μ¬ μν΄: ν΄μ¬ μμν€λ©΄ νλ©΄μ λ²μ΄λλ, timer κ° κ³μ λμ ν  μ μμ
}
```

---

πΆ π· π π π

## π Reference

Jacob's DevLog - [https://jacobko.info/ios/ios-07/](https://jacobko.info/ios/ios-07/)

μ¬:νΈμ§ κ°λ°λΈλ‘κ·Έ - [https://dev-dream-world.tistory.com/133](https://dev-dream-world.tistory.com/133)

fastcampus - [https://fastcampus.co.kr/dev_online_iosappfinal](https://fastcampus.co.kr/dev_online_iosappfinal)
