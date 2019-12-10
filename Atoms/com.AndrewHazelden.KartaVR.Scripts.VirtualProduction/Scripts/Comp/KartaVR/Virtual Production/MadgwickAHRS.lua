_VERSION = [[Version 1.0 - March 6, 2018]]
--[[--
MadgwickAHRS.lua - 2018-03-06
Ported to Lua by Andrew Hazelden <andrew@andrewhazelden.com>

A Lua re-implementation of the open-source "Madgwick's IMU and AHRS" algorithms:
http://x-io.co.uk/open-source-imu-and-ahrs-algorithms/
http://www.x-io.co.uk/res/sw/madgwick_algorithm_c.zip


Version History
	2011-09-29 SOH Madgwick
	Initial release

	2011-02-10 SOH Madgwick
	Optimised for reduced CPU load

	2012-02-19 SOH Madgwick
	Magnetometer measurement is normalised

	2018-03-06 Andrew Hazelden
	Ported C-code example to Lua script


Install Lua 5.1 on MacOS
	Step 1. Add the Brew package manager from https://brew.sh/:
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

	Step 2. Use Brew to install lua5.1:
		brew install lua51 luajit pcre
		

Lua 5.1 CLI (Command-Line) Instructions
	Step 1. Change the working directory to the location of the "MadgwickAHRS.lua" script

	Step 1.Run the following command from the terminal:
		lua5.1 MadgwickAHRS.lua 


Script Output
[MadgwickAHRS for Lua] Version 1.0 - March 6, 2018
[Quaternion Start] 1.000000, 0.000000, 0.000000, 0.000000
[Quaternion End] 1.000000, -0.000596, 0.000414, -0.000348

--]]--


------------------------------------------------------------------------------------------
-- Variable definitions

-- Algorithm gain
local beta

-- Sample frequency in Hz
local sampleFreq = 512.0

-- 2 * proportional gain
local betaDef = 0.1

-- 2 * proportional gain (Kp)
local beta = betaDef

-- Quaternion of sensor frame relative to auxiliary frame
local q0 = 1.0
local q1 = 0.0
local q2 = 0.0
local q3 = 0.0

------------------------------------------------------------------------------------------
-- AHRS algorithm update
function MadgwickAHRSupdate(gx, gy, gz, ax, ay, az, mx, my, mz)
	local recipNorm
	local s0, s1, s2, s3
	local qDot1, qDot2, qDot3, qDot4
	local hx, hy
	local _2q0mx, _2q0my, _2q0mz, _2q1mx, _2bx, _2bz, _4bx, _4bz, _2q0, _2q1, _2q2, _2q3, _2q0q2, _2q2q3, q0q0, q0q1, q0q2, q0q3, q1q1, q1q2, q1q3, q2q2, q2q3, q3q3

	-- Use IMU algorithm if magnetometer measurement invalid (avoids NaN in magnetometer normalisation)
	if((mx == 0.0) and (my == 0.0) and (mz == 0.0)) then
		MadgwickAHRSupdateIMU(gx, gy, gz, ax, ay, az)
		return
	end

	-- Rate of change of quaternion from gyroscope
	qDot1 = 0.5 * (-q1 * gx - q2 * gy - q3 * gz)
	qDot2 = 0.5 * (q0 * gx + q2 * gz - q3 * gy)
	qDot3 = 0.5 * (q0 * gy - q1 * gz + q3 * gx)
	qDot4 = 0.5 * (q0 * gz + q1 * gy - q2 * gx)

	-- Compute feedback only if accelerometer measurement valid (avoids NaN in accelerometer normalisation)
	if(not((ax == 0.0) and (ay == 0.0) and (az == 0.0))) then
		-- Normalise accelerometer measurement
		recipNorm = invSqrt(ax * ax + ay * ay + az * az)
		ax = ax * recipNorm
		ay = ay * recipNorm
		az = az * recipNorm

		-- Normalise magnetometer measurement
		recipNorm = invSqrt(mx * mx + my * my + mz * mz)
		mx = mx * recipNorm
		my = my * recipNorm
		mz = mz * recipNorm

		-- Auxiliary variables to avoid repeated arithmetic
		_2q0mx = 2.0 * q0 * mx
		_2q0my = 2.0 * q0 * my
		_2q0mz = 2.0 * q0 * mz
		_2q1mx = 2.0 * q1 * mx
		_2q0 = 2.0 * q0
		_2q1 = 2.0 * q1
		_2q2 = 2.0 * q2
		_2q3 = 2.0 * q3
		_2q0q2 = 2.0 * q0 * q2
		_2q2q3 = 2.0 * q2 * q3
		q0q0 = q0 * q0
		q0q1 = q0 * q1
		q0q2 = q0 * q2
		q0q3 = q0 * q3
		q1q1 = q1 * q1
		q1q2 = q1 * q2
		q1q3 = q1 * q3
		q2q2 = q2 * q2
		q2q3 = q2 * q3
		q3q3 = q3 * q3

		-- Reference direction of Earth's magnetic field
		hx = mx * q0q0 - _2q0my * q3 + _2q0mz * q2 + mx * q1q1 + _2q1 * my * q2 + _2q1 * mz * q3 - mx * q2q2 - mx * q3q3

		hy = _2q0mx * q3 + my * q0q0 - _2q0mz * q1 + _2q1mx * q2 - my * q1q1 + my * q2q2 + _2q2 * mz * q3 - my * q3q3

		_2bx = sqrt(hx * hx + hy * hy)

		_2bz = -_2q0mx * q2 + _2q0my * q1 + mz * q0q0 + _2q1mx * q3 - mz * q1q1 + _2q2 * my * q3 - mz * q2q2 + mz * q3q3

		_4bx = 2.0 * _2bx

		_4bz = 2.0 * _2bz

		-- Gradient decent algorithm corrective step
		s0 = -_2q2 * (2.0 * q1q3 - _2q0q2 - ax) + _2q1 * (2.0 * q0q1 + _2q2q3 - ay) - _2bz * q2 * (_2bx * (0.5 - q2q2 - q3q3) + _2bz * (q1q3 - q0q2) - mx) + (-_2bx * q3 + _2bz * q1) * (_2bx * (q1q2 - q0q3) + _2bz * (q0q1 + q2q3) - my) + _2bx * q2 * (_2bx * (q0q2 + q1q3) + _2bz * (0.5 - q1q1 - q2q2) - mz)

		s1 = _2q3 * (2.0 * q1q3 - _2q0q2 - ax) + _2q0 * (2.0 * q0q1 + _2q2q3 - ay) - 4.0 * q1 * (1 - 2.0 * q1q1 - 2.0 * q2q2 - az) + _2bz * q3 * (_2bx * (0.5 - q2q2 - q3q3) + _2bz * (q1q3 - q0q2) - mx) + (_2bx * q2 + _2bz * q0) * (_2bx * (q1q2 - q0q3) + _2bz * (q0q1 + q2q3) - my) + (_2bx * q3 - _4bz * q1) * (_2bx * (q0q2 + q1q3) + _2bz * (0.5 - q1q1 - q2q2) - mz)

		s2 = -_2q0 * (2.0 * q1q3 - _2q0q2 - ax) + _2q3 * (2.0 * q0q1 + _2q2q3 - ay) - 4.0 * q2 * (1 - 2.0 * q1q1 - 2.0 * q2q2 - az) + (-_4bx * q2 - _2bz * q0) * (_2bx * (0.5 - q2q2 - q3q3) + _2bz * (q1q3 - q0q2) - mx) + (_2bx * q1 + _2bz * q3) * (_2bx * (q1q2 - q0q3) + _2bz * (q0q1 + q2q3) - my) + (_2bx * q0 - _4bz * q2) * (_2bx * (q0q2 + q1q3) + _2bz * (0.5 - q1q1 - q2q2) - mz)

		s3 = _2q1 * (2.0 * q1q3 - _2q0q2 - ax) + _2q2 * (2.0 * q0q1 + _2q2q3 - ay) + (-_4bx * q3 + _2bz * q1) * (_2bx * (0.5 - q2q2 - q3q3) + _2bz * (q1q3 - q0q2) - mx) + (-_2bx * q0 + _2bz * q2) * (_2bx * (q1q2 - q0q3) + _2bz * (q0q1 + q2q3) - my) + _2bx * q1 * (_2bx * (q0q2 + q1q3) + _2bz * (0.5 - q1q1 - q2q2) - mz)

		-- Normalise step magnitude
		recipNorm = invSqrt(s0 * s0 + s1 * s1 + s2 * s2 + s3 * s3)
		s0 = s0 * recipNorm
		s1 = s1 * recipNorm
		s2 = s2 * recipNorm
		s3 = s3 * recipNorm

		-- Apply feedback step
		qDot1 = (beta * s0) - qDot1
		qDot2 = (beta * s1) - qDot2
		qDot3 = (beta * s2) - qDot3
		qDot4 = (beta * s3) - qDot4
	end

	-- Integrate rate of change of quaternion to yield quaternion
	q0 = q0 + qDot1 * (1.0 / sampleFreq)
	q1 = q1 + qDot2 * (1.0 / sampleFreq)
	q2 = q2 + qDot3 * (1.0 / sampleFreq)
	q3 = q3 + qDot4 * (1.0 / sampleFreq)

	-- Normalise quaternion
	recipNorm = invSqrt(q0 * q0 + q1 * q1 + q2 * q2 + q3 * q3)
	q0 = q0 * recipNorm
	q1 = q1 * recipNorm
	q2 = q2 * recipNorm
	q3 = q3 * recipNorm
end

------------------------------------------------------------------------------------------
-- IMU algorithm update
function MadgwickAHRSupdateIMU(gx, gy, gz, ax, ay, az)
	local recipNorm
	local s0, s1, s2, s3
	local qDot1, qDot2, qDot3, qDot4
	local _2q0, _2q1, _2q2, _2q3, _4q0, _4q1, _4q2, _8q1, _8q2, q0q0, q1q1, q2q2, q3q3

	-- Rate of change of quaternion from gyroscope
	qDot1 = 0.5 * (-q1 * gx - q2 * gy - q3 * gz)
	qDot2 = 0.5 * (q0 * gx + q2 * gz - q3 * gy)
	qDot3 = 0.5 * (q0 * gy - q1 * gz + q3 * gx)
	qDot4 = 0.5 * (q0 * gz + q1 * gy - q2 * gx)

	-- Compute feedback only if accelerometer measurement valid (avoids NaN in accelerometer normalisation)
	if(not((ax == 0.0) and (ay == 0.0) and (az == 0.0))) then
		-- Normalise accelerometer measurement
		recipNorm = invSqrt(ax * ax + ay * ay + az * az)
		ax = ax * recipNorm
		ay = ay * recipNorm
		az = az * recipNorm

		-- Auxiliary variables to avoid repeated arithmetic
		_2q0 = 2.0 * q0
		_2q1 = 2.0 * q1
		_2q2 = 2.0 * q2
		_2q3 = 2.0 * q3
		_4q0 = 4.0 * q0
		_4q1 = 4.0 * q1
		_4q2 = 4.0 * q2
		_8q1 = 8.0 * q1
		_8q2 = 8.0 * q2
		q0q0 = q0 * q0
		q1q1 = q1 * q1
		q2q2 = q2 * q2
		q3q3 = q3 * q3

		-- Gradient decent algorithm corrective step
		s0 = _4q0 * q2q2 + _2q2 * ax + _4q0 * q1q1 - _2q1 * ay

		s1 = _4q1 * q3q3 - _2q3 * ax + 4.0 * q0q0 * q1 - _2q0 * ay - _4q1 + _8q1 * q1q1 + _8q1 * q2q2 + _4q1 * az

		s2 = 4.0 * q0q0 * q2 + _2q0 * ax + _4q2 * q3q3 - _2q3 * ay - _4q2 + _8q2 * q1q1 + _8q2 * q2q2 + _4q2 * az

		s3 = 4.0 * q1q1 * q3 - _2q1 * ax + 4.0 * q2q2 * q3 - _2q2 * ay

		-- Normalise step magnitude
		recipNorm = invSqrt(s0 * s0 + s1 * s1 + s2 * s2 + s3 * s3)
		s0 = s0 * recipNorm
		s1 = s1 * recipNorm
		s2 = s2 * recipNorm
		s3 = s3 * recipNorm

		-- Apply feedback step
		qDot1 = (beta * s0) - qDot1
		qDot2 = (beta * s1) - qDot2
		qDot3 = (beta * s2) - qDot3
		qDot4 = (beta * s3) - qDot4
	end

	-- Integrate rate of change of quaternion to yield quaternion
	q0 = q0 + qDot1 * (1.0 / sampleFreq)
	q1 = q1 + qDot2 * (1.0 / sampleFreq)
	q2 = q2 + qDot3 * (1.0 / sampleFreq)
	q3 = q3 + qDot4 * (1.0 / sampleFreq)

	-- Normalise quaternion
	recipNorm = invSqrt(q0 * q0 + q1 * q1 + q2 * q2 + q3 * q3)
	q0 = q0 * recipNorm
	q1 = q1 * recipNorm
	q2 = q2 * recipNorm
	q3 = q3 * recipNorm
end

------------------------------------------------------------------------------------------
-- Inverse Square-root
function invSqrt(x)
	return 1/math.sqrt(x)
end

------------------------------------------------------------------------------------------
-- Where the magic happens
function Main()
	print('\n\n')
	print('[MadgwickAHRS for Lua] ' .. _VERSION)
	print('[Ported By] Andrew Hazelden <andrew@andrewhazelden.com>')
	print('----------------------------------------------------------')

	local globalTime = 0
	local gx, gy, gz = 0.551797603195739, -0.23302263648468707, 0.35605858854860184
	local ax, ay, az = 7.564593301435407, 2.3301435406698565, 1.6411483253588517

	print(string.format('[Quaternion Start] %f, %f, %f, %f', q0, q1, q2, q3))

	MadgwickAHRSupdateIMU(gx, gy, gz, ax, ay, az)
	print(string.format('[Quaternion End] %f, %f, %f, %f', q0, q1, q2, q3))

	print('----------------------------------------------------------')
	print('[Done]\n\n')
end

Main()
