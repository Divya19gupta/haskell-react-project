import React, { useState } from 'react';
import axios from 'axios';

const App = () => {
    const [choice, setChoice] = useState('');
    const [subChoice, setSubChoice] = useState('');
    const [inputs, setInputs] = useState({});
    const [result, setResult] = useState('');

    // Handle form submission
    const handleSubmit = async (event) => {
        event.preventDefault();
        debugger;
        try {
            const response = await axios.post('http://localhost:8000', {
                choice,
                subChoice,
                ...inputs
            });
           
            setResult(response.data.result);
        } catch (error) {
            console.error('There was an error making the request:', error);
            setResult('Error occurred');
        }
    };

    // Handle input changes
    const handleInputChange = (event) => {
        const { name, value } = event.target;
        setInputs({ ...inputs, [name]: value });
    };

    return (
        <div className="App">
            <h1>Physics Calculator</h1>
            <form onSubmit={handleSubmit}>
                <div>
                    <label>
                        Problem Type:
                        <select value={choice} onChange={(e) => setChoice(e.target.value)}>
                            <option value="">Select</option>
                            <option value="displacement">Displacement</option>
                            <option value="acceleration">Acceleration</option>
                            <option value="velocity">Velocity</option>
                        </select>
                    </label>
                </div>
                {choice && (
                    <div>
                        <label>
                            Sub-Problem Type:
                            <select value={subChoice} onChange={(e) => setSubChoice(e.target.value)}>
                                <option value="">Select</option>
                                {/* Displacement options */}
                                {choice === 'displacement' && (
                                    <>
                                        <option value="1">Initial and Final Positions</option>
                                        <option value="2">Initial Velocity, Acceleration, and Time</option>
                                    </>
                                )}
                                {/* Acceleration options */}
                                {choice === 'acceleration' && (
                                    <>
                                        <option value="1">Initial and Final Velocity</option>
                                        <option value="2">Force and Mass</option>
                                    </>
                                )}
                                {/* Velocity options */}
                                {choice === 'velocity' && (
                                    <>
                                        <option value="1">Initial Velocity, Acceleration, and Time</option>
                                        <option value="2">Final Velocity, Initial Velocity, and Time</option>
                                    </>
                                )}
                            </select>
                        </label>
                    </div>
                )}
                <div>
                    {/* Render input fields dynamically based on choice and subChoice */}
                    {choice === 'displacement' && subChoice === '1' && (
                        <>
                            <label>
                                Initial Position (m):
                                <input type="number" name="initialPosition" onChange={handleInputChange} />
                            </label>
                            <label>
                                Final Position (m):
                                <input type="number" name="finalPosition" onChange={handleInputChange} />
                            </label>
                        </>
                    )}
                    {choice === 'displacement' && subChoice === '2' && (
                        <>
                            <label>
                                Initial Velocity (m/s):
                                <input type="number" name="initialVelocity" onChange={handleInputChange} />
                            </label>
                            <label>
                                Acceleration (m/s²):
                                <input type="number" name="acceleration" onChange={handleInputChange} />
                            </label>
                            <label>
                                Time (s):
                                <input type="number" name="time" onChange={handleInputChange} />
                            </label>
                        </>
                    )}
                    {/* Add similar blocks for other choices and subChoices */}
                </div>
                <button type="submit">Calculate</button>
            </form>
            <h2>Result:</h2>
            <p>{result}</p>
        </div>
    );
};

export default App;
